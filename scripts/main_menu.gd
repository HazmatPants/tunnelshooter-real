extends Node3D

var link_cooldown = 0.0

func _ready() -> void:
	GLOBAL.init()
	GLOBAL.player.give_rand_gun()

func _process(delta: float) -> void:
	GLOBAL.player.reserve_ammo = 922339203685477580

	link_cooldown -= delta
	link_cooldown = maxf(link_cooldown, 0.0)

func _hit_by_bullet(hit):
	if hit == $ShootingRangeButton:
		GLOBAL.player.give_gun("")
		await get_tree().create_timer(0.1).timeout
		GLOBAL.switch_to_scene(preload("res://scenes/shooting_range.tscn"))
	if hit == $GodotButton and link_cooldown <= 0.0:
		OS.shell_open("https://godotengine.org")
		link_cooldown = 1.0
	if hit == $GitHubButton and link_cooldown <= 0.0:
		OS.shell_open("https://github.com/HazmatPants/tunnelshooter-real")
		link_cooldown = 1.0
	if hit == $UserDirButton and link_cooldown <= 0.0:
		OS.shell_open(ProjectSettings.globalize_path("user://"))
		link_cooldown = 1.0
