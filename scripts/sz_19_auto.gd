extends gun_SZ19

func _ready() -> void:
	slide_base_pos = slide.position
	full_auto = true
	gunpunch = 0.05
	max_ammo = 24
	ammo = max_ammo
	plus_one = false
	recoil_amount = 0.05
	recoil_recovery = 0.8
	trigger_time = 0.075
	viewpunch = 0.05
	bullet_energy = 10.0
	bullet_penetration = 5.0
