class_name BasePistol
extends Node3D

@onready var ray: RayCast3D = $RayCast3D
@onready var anim: AnimationPlayer = $AnimationPlayer

var full_auto: bool = false
var plus_one: bool = true
var recoil_amount: float = 0.1
var recoil_recovery: float = 0.6
var trigger_time: float = 0.05
var viewpunch: float = 0.2
var gunpunch: float = 0.33
var bullet_energy: float = 20.0
var bullet_penetration: float = 5.0
var ads_speed: float = 0.2

var max_ammo: int = 12
var ammo: int = 0

var sfx_shoot = preload("res://assets/audio/sfx/weapons/caliber/45_crack.wav")
var sfx_crack = preload("res://assets/audio/sfx/weapons/caliber/45_shoot.wav")

signal reload_finished

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

	get_parent().spawn_casing($CasingPos.global_transform, $CasingPos.global_transform.basis.x.normalized())

	get_parent().shoot(ray, bullet_energy, bullet_penetration)

func playsound(stream: AudioStream, volume: float=1.0):
	GLOBAL.playsound3d(stream, global_position, volume)

func apply_punch(dir_min: Vector3, dir_max: Vector3):
	get_parent().punch_target += Vector3(
		randf_range(dir_min.x, dir_max.x),
		randf_range(dir_min.y, dir_max.y),
		randf_range(dir_min.z, dir_max.z)
	)

func apply_hard_punch(dir_min: Vector3, dir_max: Vector3):
	get_parent().punch += Vector3(
		randf_range(dir_min.x, dir_max.x),
		randf_range(dir_min.y, dir_max.y),
		randf_range(dir_min.z, dir_max.z)
	)

func play_rand_sound(streams: Array, volume: float=1.0):
	GLOBAL.playsound3d(GLOBAL.randsfx(streams), global_position, volume)

func reload():
	GLOBAL.player.gun_controller.reloading = true
	anim.play("reload")
	await anim.animation_finished
	if ammo == 0:
		await get_tree().create_timer(0.1).timeout
		anim.play("prime")
		GLOBAL.player.reload_anim("prime")
		await anim.animation_finished
	GLOBAL.player.gun_controller.reloading = false
	reload_finished.emit()
	if GLOBAL.player.reserve_ammo < max_ammo - ammo:
		ammo += GLOBAL.player.reserve_ammo
		GLOBAL.player.reserve_ammo = 0
	elif ammo == 0:
		GLOBAL.player.reserve_ammo -= max_ammo - ammo
		ammo = max_ammo
	else:
		GLOBAL.player.reserve_ammo -= (max_ammo + 1) - ammo
		ammo = max_ammo + 1
