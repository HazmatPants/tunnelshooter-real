extends Node3D

func _ready() -> void:
	for light in $Lights.get_children():
		if light is Light3D:
			light.visible = false

	await get_tree().create_timer(2.0).timeout

	GLOBAL.playsound(preload("res://assets/audio/sfx/ambient/massive_light_switch.ogg"))

	for light in $Lights.get_children():
		if light is Light3D:
			light.visible = true
