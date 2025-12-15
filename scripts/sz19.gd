extends Node3D

@onready var ray: RayCast3D = $RayCast3D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var slide: MeshInstance3D = $Slide

@export var full_auto: bool = false
@export var plus_one: bool = false
@export var recoil_amount: float = 0.1
@export var recoil_recovery: float = 0.6
@export var trigger_time: float = 0.075
@export var viewpunch: float = 0.2
@export var gunpunch: float = 0.2
@export var bullet_energy: float = 20.0
@export var bullet_penetration: float = 5.0

@export var max_ammo: int = 8
var ammo: int = 0

const sfx_shoot = preload("res://assets/audio/sfx/weapons/caliber/45_crack.wav")
const sfx_crack = preload("res://assets/audio/sfx/weapons/caliber/45_shoot.wav")

var slide_base_pos: Vector3

signal reload_finished

func _ready() -> void:
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

func playsound(stream: AudioStream, volume: float=1.0):
	GLOBAL.playsound3d(stream, global_position, volume)

func play_rand_sound(streams: Array, volume: float=1.0):
	GLOBAL.playsound3d(GLOBAL.randsfx(streams), global_position, volume)

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

func reload():
	GLOBAL.player.gun_controller.reloading = true
	if ammo > 0:
		anim.play("slideback")
		await anim.animation_finished
	while ammo < max_ammo and GLOBAL.player.reserve_ammo > 0:
		if ammo > max_ammo - 8 or GLOBAL.player.reserve_ammo < 8:
			while ammo < max_ammo:
				anim.play("reload_1")
				await anim.animation_finished
				ammo += 1
				GLOBAL.player.reserve_ammo -= 1
				if !GLOBAL.player.reserve_ammo > 0:
					break
		elif GLOBAL.player.reserve_ammo >= 8:
			while ammo <= max_ammo - 8:
				anim.play("reload_clip")
				ammo += 8
				GLOBAL.player.reserve_ammo -= 8
				await anim.animation_finished
				if !GLOBAL.player.reserve_ammo > 8:
					break
	await get_tree().create_timer(0.1).timeout
	anim.play("prime")
	await anim.animation_finished
	GLOBAL.player.gun_controller.reloading = false
	reload_finished.emit()
