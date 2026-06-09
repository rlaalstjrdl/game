extends Button

var slot_index: int = -1

func _get_drag_data(at_position):
	if slot_index < 0 or slot_index >= Inventory.MAX_SLOTS:
		return null
		
	var item_name = Inventory.items[slot_index]
	if item_name == null or item_name == "":
		return null
		
	var data = {"source_index": slot_index}
	

	var preview_label = Label.new()
	preview_label.text = item_name
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var preview = ColorRect.new()
	preview.color = Color(0.2, 0.2, 0.2, 0.8)
	preview.custom_minimum_size = Vector2(70, 70)
	preview.add_child(preview_label)
	preview_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	set_drag_preview(preview)
	
	return data

func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("source_index")

func _drop_data(at_position, data):
	var source_index = data["source_index"]
	if source_index != slot_index:
		Inventory.swap_items(source_index, slot_index)
