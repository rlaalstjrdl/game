extends CharacterBody3D

const SPEED = 2.0
const JUMP_VELOCITY = 4.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var max_health = 15
var health = 15
var state = "idle"
var state_timer = 0.0
var step_timer = 0.0
var move_dir = Vector3.ZERO

@onready var progress_bar = $HealthViewport/ProgressBar
var damage_text_scene = preload("res://scenes/damage_text.tscn")

func _ready():
	update_health_bar()
	pick_new_state()

func _physics_process(delta):

	if not is_on_floor():
		velocity.y -= gravity * delta


	state_timer -= delta
	if state_timer <= 0:
		pick_new_state()
		
	if state == "walk":
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
		

		var target_angle = atan2(velocity.x, velocity.z)
		$Visuals.rotation.y = lerp_angle($Visuals.rotation.y, target_angle, 10.0 * delta)
		

		if is_on_floor():
			step_timer -= delta
			if step_timer <= 0:
				if has_node("StepSoundPlayer"):
					$StepSoundPlayer.play()
				step_timer = 0.4
		

		if is_on_floor() and randf() < 0.01:
			velocity.y = JUMP_VELOCITY
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func pick_new_state():
	if randf() > 0.5:
		state = "idle"
		state_timer = randf_range(1.0, 3.0)
	else:
		state = "walk"
		state_timer = randf_range(2.0, 5.0)
		var random_angle = randf() * TAU
		move_dir = Vector3(sin(random_angle), 0, cos(random_angle)).normalized()
		

	if randf() < 0.3:
		if has_node("SoundPlayer"):
			$SoundPlayer.play()

func update_health_bar():
	if progress_bar:
		progress_bar.max_value = max_health
		progress_bar.value = health

func take_damage(amount: float, is_critical: bool):
	health -= amount
	update_health_bar()
	

	var dt = damage_text_scene.instantiate()
	get_parent().add_child(dt)
	dt.global_position = global_position + Vector3(0, 1.5, 0)
	dt.setup(amount, is_critical)
	
	if health <= 0:
		queue_free()
