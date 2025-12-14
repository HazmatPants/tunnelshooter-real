extends Control

@onready var list = $VBoxContainer

func _ready() -> void:
	refresh_list()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_P and event.pressed:
			visible = !visible
			if visible:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func refresh_list():
	for child in list.get_children():
		child.queue_free()

	var guns = GLOBAL.GUNS

	for gun in guns:
		print(gun)
		if gun == "NONE": continue
		var button := Button.new()
		button.text = GLOBAL.GUN_NAMES[GLOBAL.GUNS[gun]]
		button.pressed.connect(give_gun.bind(GLOBAL.GUNS[gun]))
		list.add_child(button)
	await list.resized
	$Panel.size = list.size
	$Panel.pivot_offset = list.size / 2
	$Panel.position = list.position

func give_gun(gun: GLOBAL.GUNS):
	GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_attach.ogg"), 1.0, 1.0, "Master")
	GLOBAL.player.give_gun(gun)
