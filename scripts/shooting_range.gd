extends Node3D

func _ready() -> void:
	AudioServer.get_bus_effect(1, 0).room_size = 0.4
	AudioServer.get_bus_effect(1, 0).damping = 0.5
	AudioServer.get_bus_effect(1, 0).predelay_msec = 100.0
	AudioServer.get_bus_effect(1, 0).wet = 0.5

	GLOBAL.init()
	for light in $Lights.get_children():
		if light is Light3D:
			light.visible = false

	GLOBAL.player.give_rand_gun()

	await get_tree().create_timer(1.0).timeout

	GLOBAL.playsound(preload("res://assets/audio/sfx/ambient/massive_light_switch.ogg"))

	for light in $Lights.get_children():
		if light is Light3D:
			light.visible = true
