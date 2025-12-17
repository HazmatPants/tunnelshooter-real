class_name gun_SZ19
extends BasePistol

@onready var slide: MeshInstance3D = $Slide

var slide_base_pos: Vector3

func _ready() -> void:
	ammo = max_ammo
	slide_base_pos = slide.position
	plus_one = false
	recoil_amount = 0.1
	recoil_recovery = 0.6
	trigger_time = 0.075
	viewpunch = 0.2
	gunpunch = 0.2
	bullet_energy = 10.0
	bullet_penetration = 5.0

	max_ammo = 8
	ammo = max_ammo

	sfx_shoot = preload("res://assets/audio/sfx/weapons/caliber/45_crack.wav")
	sfx_crack = preload("res://assets/audio/sfx/weapons/caliber/45_shoot.wav")

func shoot():
	ammo -= 1
	slide.position.z = slide_base_pos.z + 0.2
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

	get_parent().spawn_casing($CasingPos.global_transform, $CasingPos.global_transform.basis.y)

	get_parent().shoot(ray, bullet_energy, bullet_penetration)

func _process(_delta: float) -> void:
	if ammo <= 0 or GLOBAL.player.gun_controller.reloading:
		slide.position.z = slide_base_pos.z + 0.125
	slide.position = slide.position.lerp(slide_base_pos, 0.2)

	if Input.is_action_pressed("lmb"):
		_reload_cancel = true

var _reload_cancel
func reload():
	GLOBAL.player.gun_controller.reloading = true
	_reload_cancel = false
	if ammo > 0:
		anim.play("slideback")
		await anim.animation_finished
	while ammo < max_ammo and GLOBAL.player.reserve_ammo > 0:
		if _reload_cancel:
			break
		if ammo > max_ammo - 8 or GLOBAL.player.reserve_ammo < 8:
			while ammo < max_ammo:
				anim.play("reload_1")
				await anim.animation_finished
				ammo += 1
				GLOBAL.player.reserve_ammo -= 1
				if !GLOBAL.player.reserve_ammo > 0 or _reload_cancel:
					break
		elif GLOBAL.player.reserve_ammo >= 8:
			while ammo <= max_ammo - 8:
				anim.play("reload_clip")
				ammo += 8
				GLOBAL.player.reserve_ammo -= 8
				await anim.animation_finished
				if !GLOBAL.player.reserve_ammo > 8 or _reload_cancel:
					break
	await get_tree().create_timer(0.1).timeout
	anim.play("prime")
	await anim.animation_finished
	GLOBAL.player.gun_controller.reloading = false
	reload_finished.emit()
