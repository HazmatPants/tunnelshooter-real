extends StaticBody3D

func _process(_delta: float) -> void:
	var score_label = $MeshInstance3D2/Label3D

	if score_label != null:
		score_label.text = str(ScoreManager.score)

func _hit_by_bullet(_hit):
	ScoreManager.score = 0
	GLOBAL.playsound3d(preload("res://assets/audio/sfx/ui/target_hit.wav"), global_position)
	GLOBAL.playsound3d(preload("res://assets/audio/sfx/physics/zap.ogg"), global_position)
