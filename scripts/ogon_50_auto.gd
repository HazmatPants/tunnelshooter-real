extends gun_Ogon50

func _ready() -> void:
	slide_base_pos = slide.position
	full_auto = true
	trigger_time = 0.1

	max_ammo = 12
	ammo = max_ammo
