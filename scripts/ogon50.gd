class_name gun_Ogon50
extends BasePistol

@onready var slide: MeshInstance3D = $Slide
var slide_base_pos: Vector3

func _ready() -> void:
	sfx_shoot = preload("res://assets/audio/sfx/weapons/caliber/50_shoot.wav")
	sfx_crack = preload("res://assets/audio/sfx/weapons/caliber/45_crack.wav")
	trigger_time = 0.2
	ammo = max_ammo
	slide_base_pos = slide.position

func shoot():
	ammo -= 1
	slide.position.z = slide_base_pos.z + 0.2
	GLOBAL.playsound3d(sfx_shoot, global_position, 1.0, randf_range(0.98, 1.02))
	GLOBAL.playsound3d(sfx_crack, global_position, randf_range(0.05, 0.2), randf_range(1.0, 1.25))
	var muzzflash = preload("res://scenes/muzzle_flash.tscn").instantiate()
	get_tree().current_scene.add_child(muzzflash)
	muzzflash.global_position = ray.global_position

	get_parent().punch += Vector3(
		randf_range(-0.02, 0.02),
		randf_range(-0.02, 0.02),
		0.0
	)

	GLOBAL.player.viewpunch_target += Vector3(viewpunch, 0, randf_range(-viewpunch, viewpunch))

	get_parent().spawn_casing($CasingPos.global_transform, $CasingPos.global_transform.basis.y)

	get_parent().shoot(ray, bullet_energy, bullet_penetration)

func _process(_delta: float) -> void:
	if ammo <= 0:
		slide.position.z = slide_base_pos.z + 0.125
	slide.position = slide.position.lerp(slide_base_pos, 0.2)

func reload():
	GLOBAL.player.gun_controller.reloading = true
	anim.play("reload")
	await anim.animation_finished
	if ammo == 0:
		await get_tree().create_timer(0.1).timeout
		anim.play("prime")
		await anim.animation_finished
	GLOBAL.player.gun_controller.reloading = false
	reload_finished.emit()
	if GLOBAL.player.reserve_ammo < max_ammo:
		ammo += GLOBAL.player.reserve_ammo
		GLOBAL.player.reserve_ammo = 0
	elif ammo == 0:
		GLOBAL.player.reserve_ammo -= max_ammo - ammo
		ammo = max_ammo
	else:
		GLOBAL.player.reserve_ammo -= (max_ammo + 1) - ammo
		ammo = max_ammo + 1
