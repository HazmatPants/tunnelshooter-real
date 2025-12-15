extends Node3D

func _ready() -> void:
	AudioServer.get_bus_effect(1, 0).room_size = 0.1
	AudioServer.get_bus_effect(1, 0).damping = 1.0
	AudioServer.get_bus_effect(1, 0).predelay_msec = 20.0
	AudioServer.get_bus_effect(1, 0).predelay_feedback = 0.4
	AudioServer.get_bus_effect(1, 0).wet = 1.0

	GLOBAL.player.give_rand_gun()

func _process(_delta: float) -> void:
	GLOBAL.player.reserve_ammo = 922339203685477580

func _hit_by_bullet(hit):
	if hit == $ShootingRangeButton:
		GLOBAL.player.give_gun(GLOBAL.GUNS.NONE)
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://scenes/shooting_range.tscn")
