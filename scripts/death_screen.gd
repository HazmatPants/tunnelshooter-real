extends Node3D

func _ready() -> void:
	GLOBAL.init()
	GLOBAL.player.give_rand_gun()

	if GLOBAL.player_fatal_hit:
		$FatalHitLabel.text = "Fatal hit: %s" % GLOBAL.player_fatal_hit.capitalize()

func _process(_delta: float) -> void:
	GLOBAL.player.reserve_ammo = 922339203685477580

func _hit_by_bullet(hit):
	if hit == $MainMenuButton:
		GLOBAL.player.give_gun("")
		await get_tree().create_timer(0.1).timeout
		GLOBAL.switch_to_scene(preload("res://scenes/main_menu.tscn"))
