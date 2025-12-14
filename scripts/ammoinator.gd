extends Node3D

var player_in_area: bool = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == GLOBAL.player:
		player_in_area = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == GLOBAL.player:
		player_in_area = false

func _process(_delta: float) -> void:
	if player_in_area:
		GLOBAL.player.reserve_ammo += 1
		await get_tree().create_timer(0.1).timeout
