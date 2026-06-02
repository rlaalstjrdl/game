extends Node

# Simple inventory system
signal inventory_changed

var items: Array[String] = []
var max_slots: int = 15

func _ready():
	# Starting items
	add_item("삽 (Shovel)")
	add_item("도끼 (Axe)")

func add_item(item_name: String) -> bool:
	if items.size() < max_slots:
		items.append(item_name)
		inventory_changed.emit()
		return true
	return false

func remove_item(index: int):
	if index >= 0 and index < items.size():
		items.remove_at(index)
		inventory_changed.emit()
