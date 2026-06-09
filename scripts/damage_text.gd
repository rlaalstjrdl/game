extends Node3D

@onready var label = $Label3D

func setup(amount: float, is_critical: bool):
	label.text = str(amount)
	if is_critical:
		label.modulate = Color.DARK_RED
		label.outline_modulate = Color.WHITE
		label.scale = Vector3(1.5, 1.5, 1.5)
	else:
		label.modulate = Color.WHITE

func _ready():
	var tween = create_tween()

	tween.tween_property(self, "position:y", position.y + 1.5, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0).set_delay(0.5)
	tween.tween_callback(queue_free)
