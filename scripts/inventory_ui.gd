extends Control

@onready var grid = $Panel/GridContainer

func _ready():
	Inventory.inventory_changed.connect(update_ui)
	update_ui()
	hide() # Hide by default

func _input(event):
	if event.is_action_pressed("toggle_inventory") or (event is InputEventKey and event.keycode == KEY_TAB and event.pressed):
		visible = not visible

func update_ui():
	# Clear existing
	for child in grid.get_children():
		child.queue_free()
		
	# Add items
	for item in Inventory.items:
		var btn = Button.new()
		btn.text = item
		btn.custom_minimum_size = Vector2(70, 70)
		grid.add_child(btn)
