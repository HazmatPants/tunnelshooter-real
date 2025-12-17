extends gun_GI_Mk_1

func _ready() -> void:
	slide_base_pos = slide.position
	full_auto = true
	gunpunch = 0.1

	max_ammo = 30
	ammo = max_ammo
