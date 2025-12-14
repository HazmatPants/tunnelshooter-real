extends Node3D

const SFX_HIT = [
	preload("res://assets/audio/sfx/ui/target/hit1.ogg"),
	preload("res://assets/audio/sfx/ui/target/hit2.ogg"),
	preload("res://assets/audio/sfx/ui/target/hit3.ogg"),
	preload("res://assets/audio/sfx/ui/target/hit4.ogg"),
	preload("res://assets/audio/sfx/ui/target/hit5.ogg"),
	preload("res://assets/audio/sfx/ui/target/hit6.ogg"),
	preload("res://assets/audio/sfx/ui/target/hit7.ogg"),
	preload("res://assets/audio/sfx/ui/target/hit8.ogg")
]

func _hit_by_bullet(hit):
	for child in get_children():
		if child == hit:
			GLOBAL.playsound3d(SFX_HIT[int(hit.name) - 1], global_position)
			ScoreManager.score += int(hit.name)
			child.get_node("MeshInstance3D").set_surface_override_material(0, preload("res://assets/materials/white.tres"))
			await get_tree().create_timer(0.25).timeout
			child.get_node("MeshInstance3D").set_surface_override_material(0, null)
			break
