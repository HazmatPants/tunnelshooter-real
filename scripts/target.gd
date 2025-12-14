extends Node3D

func _hit_by_bullet(hit):
	if hit == $Head:
		ScoreManager.score += 8
		GLOBAL.playsound3d(preload("res://assets/audio/sfx/ui/target/hit8.ogg"), global_position)
		$Head/MeshInstance3D.set_surface_override_material(0, preload("res://assets/materials/white.tres"))
		await get_tree().create_timer(0.25).timeout
		$Head/MeshInstance3D.set_surface_override_material(0, null)
	elif hit == $Body:
		ScoreManager.score += 5
		GLOBAL.playsound3d(preload("res://assets/audio/sfx/ui/target/hit5.ogg"), global_position)
		$Body/MeshInstance3D.set_surface_override_material(0, preload("res://assets/materials/white.tres"))
		await get_tree().create_timer(0.25).timeout
		$Body/MeshInstance3D.set_surface_override_material(0, null)
