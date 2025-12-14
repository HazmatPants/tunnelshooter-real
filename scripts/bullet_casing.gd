extends RigidBody3D

func _ready() -> void:
	var tween = create_tween()
	tween.tween_interval(20.0)
	tween.tween_property($MeshInstance3D, "scale", Vector3.ZERO, 1.0)
	tween.finished.connect(queue_free)
