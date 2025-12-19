extends gun_Ogon50

func _ready() -> void:
	sfx_shoot = preload("res://assets/audio/sfx/weapons/caliber/50_shoot.wav")
	sfx_crack = preload("res://assets/audio/sfx/weapons/caliber/45_crack.wav")
	slide_base_pos = slide.position
	full_auto = true
	trigger_time = 0.15

	max_ammo = 12
	ammo = max_ammo
