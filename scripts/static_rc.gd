class_name gun_static_rc
extends BasePistol

func _ready() -> void:
	plus_one = false
	recoil_amount = 0.1
	recoil_recovery = 0.8
	trigger_time = 0.15
	viewpunch = 0.3
	gunpunch = 0.025
	bullet_energy = 30.0
	bullet_penetration = 20.0
	ads_speed = 0.1

	max_ammo = 10
	ammo = max_ammo

	sfx_shoot = preload("res://assets/audio/sfx/weapons/static_rc/static_rc_crack.wav")
	sfx_crack = preload("res://assets/audio/sfx/weapons/caliber/50_shoot.wav")

func _process(delta: float) -> void:
	$Mesh/Counter/Label3D.text = str(ammo)

func shoot():
	ammo -= 1
	GLOBAL.playsound3d(sfx_shoot, global_position, 1.0, randf_range(0.98, 1.02))
	GLOBAL.playsound3d(sfx_crack, global_position, randf_range(0.05, 0.2), randf_range(1.0, 1.25))
	var muzzflash = preload("res://scenes/muzzle_flash.tscn").instantiate()
	get_tree().current_scene.add_child(muzzflash)
	muzzflash.global_position = ray.global_position

	GLOBAL.playsound3d(preload("res://assets/audio/sfx/weapons/sonorous.wav"), 
	$CasingPos.global_position,
	0.05,
	randf_range(0.98, 1.02))

	get_parent().punch += Vector3(
		randf_range(-0.01, 0.01),
		randf_range(-0.01, 0.01),
		0.0
	)

	GLOBAL.player.viewpunch_target += Vector3(viewpunch, 0, randf_range(-viewpunch, viewpunch))

	get_parent().shoot(ray, bullet_energy, bullet_penetration)

	if ammo <= 3:
		GLOBAL.playsound3d(preload("res://assets/audio/sfx/weapons/static_rc/static_rc_low.wav"), global_position, 0.1)

func reload():
	GLOBAL.player.gun_controller.reloading = true
	anim.play("reload")
	GLOBAL.player.reload_anim("reload")
	await anim.animation_finished
	ammo = max_ammo
	GLOBAL.player.gun_controller.reloading = false
	GLOBAL.playsound3d(preload("res://assets/audio/sfx/weapons/static_rc/static_rc_low.wav"), global_position, 0.05, 1.5)
