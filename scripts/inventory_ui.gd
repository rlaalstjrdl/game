extends Control

@onready var grid = $Panel/GridContainer
@onready var hotbar_grid = $HotbarPanel/HotbarGrid
@onready var panel = $Panel

var slot_script = preload("res://scripts/inventory_slot.gd")

func _ready():
	Inventory.inventory_changed.connect(update_ui)
	

	for i in range(Inventory.HOTBAR_SLOTS):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(70, 70)
		btn.set_script(slot_script)
		btn.slot_index = i
		hotbar_grid.add_child(btn)
		
	for i in range(Inventory.HOTBAR_SLOTS, Inventory.MAX_SLOTS):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(70, 70)
		btn.set_script(slot_script)
		btn.slot_index = i
		grid.add_child(btn)
		
	update_ui()
	panel.hide()

func _input(event):
	if event is InputEventKey and event.keycode == KEY_E and event.pressed and not event.echo:
		panel.visible = not panel.visible
		if panel.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func update_ui():

	for i in range(hotbar_grid.get_child_count()):
		var btn = hotbar_grid.get_child(i)
		var item = Inventory.items[btn.slot_index]
		btn.text = item if item != null else ""
		

	for i in range(grid.get_child_count()):
		var btn = grid.get_child(i)
		var item = Inventory.items[btn.slot_index]
		btn.text = item if item != null else ""
