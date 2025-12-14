extends OmniLight3D

var energy: float = 50.0
var fade: float = 8.0

func _process(delta: float) -> void:
	light_energy -= fade * delta
	if light_energy <= 0.0:
		queue_free()
