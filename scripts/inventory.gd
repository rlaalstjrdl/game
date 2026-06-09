extends Node

signal inventory_changed

const MAX_SLOTS = 50
const HOTBAR_SLOTS = 10


var items: Array = []

func _ready():
	items.resize(MAX_SLOTS)
	for i in range(MAX_SLOTS):
		items[i] = null
		

	items[0] = "??(Shovel)"
	items[1] = "?꾨겮 (Axe)"

func add_item(item_name: String) -> bool:
	for i in range(MAX_SLOTS):
		if items[i] == null:
			items[i] = item_name
			inventory_changed.emit()
			return true
	return false

func remove_item(index: int):
	if index >= 0 and index < MAX_SLOTS:
		items[index] = null
		inventory_changed.emit()

func swap_items(index1: int, index2: int):
	if index1 >= 0 and index1 < MAX_SLOTS and index2 >= 0 and index2 < MAX_SLOTS:
		var temp = items[index1]
		items[index1] = items[index2]
		items[index2] = temp
		inventory_changed.emit()
