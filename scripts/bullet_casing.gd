extends RigidBody3D

var type: String = "45gi"

const SFX_CASING_BOUNCE: Dictionary = {
	"9mm": [
		preload("res://assets/audio/sfx/physics/casing/9mm/9mm_bounce1.wav"),
		preload("res://assets/audio/sfx/physics/casing/9mm/9mm_bounce2.wav"),
		preload("res://assets/audio/sfx/physics/casing/9mm/9mm_bounce3.wav"),
		preload("res://assets/audio/sfx/physics/casing/9mm/9mm_bounce4.wav")
	],
	"45gi": [
		preload("res://assets/audio/sfx/physics/casing/9mm/9mm_bounce1.wav"),
		preload("res://assets/audio/sfx/physics/casing/9mm/9mm_bounce2.wav"),
		preload("res://assets/audio/sfx/physics/casing/9mm/9mm_bounce3.wav"),
		preload("res://assets/audio/sfx/physics/casing/9mm/9mm_bounce4.wav")
	],
	"50ae": [
		preload("res://assets/audio/sfx/physics/casing/50/50_bounce1.wav"),
		preload("res://assets/audio/sfx/physics/casing/50/50_bounce2.wav"),
		preload("res://assets/audio/sfx/physics/casing/50/50_bounce3.wav"),
		preload("res://assets/audio/sfx/physics/casing/50/50_bounce4.wav")
	]
}

const CASING_MESHES = {
	"9mm": preload("res://assets/res/casing/9mm.tscn"),
	"45gi": preload("res://assets/res/casing/45gi.tscn"),
	"50ae": preload("res://assets/res/casing/50ae.tscn")
}

func casing_ready() -> void:
	if type in CASING_MESHES:
		var mesh = CASING_MESHES[type].instantiate()
		print("created casing mesh with type: ", type)
		add_child(mesh)
	var tween = create_tween()
	tween.tween_interval(20.0)
	tween.tween_property($MeshInstance3D, "scale", Vector3.ZERO, 1.0)
	tween.finished.connect(queue_free)

func _on_body_entered(_body: Node) -> void:
	if linear_velocity.length() > 0.5:
		GLOBAL.playsound3d(GLOBAL.randsfx(SFX_CASING_BOUNCE[type]), global_position)
