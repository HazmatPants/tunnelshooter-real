class_name gun_GI_Mk_1
extends BasePistol

@onready var slide: MeshInstance3D = $Slide
var slide_base_pos: Vector3

func _ready() -> void:
	ammo = max_ammo
	slide_base_pos = slide.position

	recoil_amount = 0.1
	recoil_recovery = 0.6
	trigger_time = 0.075
	viewpunch = 0.2
	gunpunch = 0.2
	bullet_energy = 10.0
	bullet_penetration = 5.0

	max_ammo = 8
	ammo = max_ammo

func shoot():
	slide.position.z = slide_base_pos.z + 0.2
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


func _process(_delta: float) -> void:
	if ammo <= 0:
		slide.position.z = slide_base_pos.z + 0.125
	slide.position = slide.position.lerp(slide_base_pos, 0.2)
