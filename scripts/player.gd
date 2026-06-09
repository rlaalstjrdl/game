extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var toggle_pressed = false
var mouse_sensitivity = 0.002
var camera_pitch = 0.0
var attack_cooldown = 0.0
var step_timer = 0.0
var target_zoom = 8.0
var min_zoom = 0.5
var max_zoom = 12.0

@onready var camera_pivot = $CameraPivot
@onready var visuals = $Visuals

var pcam_1st
var pcam_3rd

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_pitch = 0.0
	
	var PCHost = preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd")
	var PCam3D = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_3d.gd")
	var PCTween = preload("res://addons/phantom_camera/scripts/resources/tween_resource.gd")
	
	var main_cam = Camera3D.new()
	add_child(main_cam)
	var host = PCHost.new()
	main_cam.add_child(host)
	
	var tween_res = PCTween.new()
	tween_res.duration = 0.5
	
	pcam_3rd = PCam3D.new()
	$CameraPivot.add_child(pcam_3rd)
	pcam_3rd.follow_mode = 2 
	pcam_3rd.follow_target = $CameraPivot
	pcam_3rd.spring_length = 8.0
	pcam_3rd.tween_resource = tween_res
	pcam_3rd.priority = 10
	
	pcam_1st = PCam3D.new()
	$Visuals.add_child(pcam_1st)
	pcam_1st.position = Vector3(0, 1.5, -0.3)
	pcam_1st.follow_mode = 1 
	pcam_1st.follow_target = $Visuals
	pcam_1st.tween_resource = tween_res
	pcam_1st.priority = 0

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				return
			if attack_cooldown <= 0:
				attack()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom -= 1.5
			target_zoom = clamp(target_zoom, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom += 1.5
			target_zoom = clamp(target_zoom, min_zoom, max_zoom)

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera_pitch -= event.relative.y * mouse_sensitivity
			camera_pitch = clamp(camera_pitch, -deg_to_rad(80), deg_to_rad(80))
			camera_pivot.rotation.x = camera_pitch
			if pcam_1st:
				pcam_1st.rotation.x = camera_pitch

func attack():
	attack_cooldown = 0.5
	
	var original_pos = visuals.position
	var tween = create_tween()
	tween.tween_property(visuals, "position:z", original_pos.z - 0.5, 0.1)
	tween.tween_property(visuals, "position:z", original_pos.z, 0.2)
	
	var space_state = get_world_3d().direct_space_state
	var cam = get_viewport().get_camera_3d()
	if not cam: return
	
	var center = get_viewport().get_visible_rect().size / 2
	var origin = cam.project_ray_origin(center)
	var normal = cam.project_ray_normal(center)
	var end = origin + normal * 15.0 # Reach past the 3rd person camera distance
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [self.get_rid()] # Exclude the player from being hit by their own crosshair
	
	var result = space_state.intersect_ray(query)
	if result:
		var target = result.collider
		# Ensure the target is actually close to the player (melee range)
		if target.global_position.distance_to(global_position) < 4.0:
			if target and target.has_method("take_damage"):
				var is_crit = randf() <= 0.15
				var damage = 1.5 if is_crit else 1.0
				target.take_damage(damage, is_crit)
				
				if is_crit and pcam_1st and pcam_3rd:
					var active_cam = pcam_1st if pcam_1st.priority > pcam_3rd.priority else pcam_3rd
					var original_rot = active_cam.rotation
					var shake_tween = create_tween()
					shake_tween.tween_property(active_cam, "rotation", original_rot + Vector3(0.15, 0.15, 0), 0.05)
					shake_tween.tween_property(active_cam, "rotation", original_rot - Vector3(0.15, 0.15, 0), 0.05)
					shake_tween.tween_property(active_cam, "rotation", original_rot, 0.05)

func _physics_process(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta
		
	if pcam_3rd:
		pcam_3rd.spring_length = lerp(pcam_3rd.spring_length, target_zoom, 10.0 * delta)
		
		if pcam_3rd.spring_length < 1.0:
			pcam_1st.priority = 20
			pcam_3rd.priority = 10
			if $Visuals.has_node("base_basic_shaded"):
				$Visuals/base_basic_shaded.visible = false
		else:
			pcam_1st.priority = 0
			pcam_3rd.priority = 10
			if $Visuals.has_node("base_basic_shaded"):
				$Visuals/base_basic_shaded.visible = true
		
	if Input.is_key_pressed(KEY_F5):
		if not toggle_pressed:
			toggle_pressed = true
			if target_zoom > 1.0:
				target_zoom = min_zoom
			else:
				target_zoom = 8.0
	else:
		toggle_pressed = false
		
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_S): input_dir.y += 1
	if Input.is_key_pressed(KEY_W): input_dir.y -= 1
	input_dir = input_dir.normalized()
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		$Visuals.rotation.y = 0 
		
		if is_on_floor():
			step_timer -= delta
			if step_timer <= 0:
				if has_node("StepSoundPlayer"):
					$StepSoundPlayer.play()
				step_timer = 0.35
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
