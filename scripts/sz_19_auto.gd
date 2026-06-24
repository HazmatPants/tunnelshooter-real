extends gun_SZ19

func _ready() -> void:
	slide_base_pos = slide.position
	full_auto = true
	gunpunch = 0.0
	max_ammo = 24
	plus_one = false
	recoil_amount = 0.01
	recoil_recovery = 0.9
	trigger_time = 0.075
	viewpunch = 0.01
	bullet_energy = 10.0
	bullet_penetration = 5.0
	hip_distance = -0.2
	ads_distance = -0.3
