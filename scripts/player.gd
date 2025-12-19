extends CharacterBody3D

@onready var camera: Camera3D = $Camera3D
@onready var camera_position = $CameraPosition
@onready var gun_controller: Node3D = $GunPosition
@onready var foot_ray: RayCast3D = $FootRay
@onready var hud: CanvasLayer = $"../PlayerHUD"
@onready var anim: AnimationPlayer = $AnimationPlayer

@export var move_speed: float = 4.0
@export var sprint_speed: float = 6.5
@export var jump_velocity: float = 4.0
@export var gravity: float = -9.8
@export var viewbob_frequency: float = 2.0
@export var viewbob_amplitude: float = 0.01
@export var ambient_viewbob: float = 0.001
@export var max_health: float = 0.5
var health: float = max_health
var health_percent: float = 1.0

@export var equipped_gun: String = ""
@export var reserve_ammo: int = 90

var hand_shakiness: float = 0.0

var mouse_delta := Vector2.ZERO
var camera_target_rotation := Vector3.ZERO
var viewpunch_target := Vector3.ZERO
var _viewpunch := Vector3.ZERO

var viewbob_time: float = 0.0

var is_moving: bool = false
var gun: Node3D

const SFX_FOOTSTEP: Dictionary = {
	"metal": [
		preload("res://assets/audio/sfx/player/footsteps/metal/metal_step1.ogg"),
		preload("res://assets/audio/sfx/player/footsteps/metal/metal_step2.ogg"),
		preload("res://assets/audio/sfx/player/footsteps/metal/metal_step3.ogg"),
		preload("res://assets/audio/sfx/player/footsteps/metal/metal_step4.ogg")
	],
	"wood": [
		preload("res://assets/audio/sfx/player/footsteps/wood/wood_step1.ogg"),
		preload("res://assets/audio/sfx/player/footsteps/wood/wood_step2.ogg"),
		preload("res://assets/audio/sfx/player/footsteps/wood/wood_step3.ogg"),
		preload("res://assets/audio/sfx/player/footsteps/wood/wood_step4.ogg")
	],
	"stone": [
		preload("res://assets/audio/sfx/player/footsteps/stone/stone_step1.ogg"),
		preload("res://assets/audio/sfx/player/footsteps/stone/stone_step2.ogg"),
		preload("res://assets/audio/sfx/player/footsteps/stone/stone_step3.ogg"),
		preload("res://assets/audio/sfx/player/footsteps/stone/stone_step4.ogg")
	]
}

const SFX_FLESH_HIT = [
	preload("res://assets/audio/sfx/physics/flesh/flesh_hit_1.wav"),
	preload("res://assets/audio/sfx/physics/flesh/flesh_hit_2.wav"),
	preload("res://assets/audio/sfx/physics/flesh/flesh_hit_3.wav"),
	preload("res://assets/audio/sfx/physics/flesh/flesh_hit_4.wav"),
	preload("res://assets/audio/sfx/physics/flesh/flesh_hit_5.wav"),
	preload("res://assets/audio/sfx/physics/flesh/flesh_hit_6.wav")
]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_delta += event.relative
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	health_percent = health / max_health

	if health_percent <= 0.0:
		get_tree().change_scene_to_file("res://scenes/death_screen.tscn")

var trigger_time: float = 0.0
var last_viewbob_sine: float = 0.0
var was_on_floor: bool = true
var step_side: bool = true
var was_moving: bool = false
var trigger_pulled: bool = false
var shot: bool = false
func _physics_process(delta: float) -> void:
	var input_vector := Vector3.ZERO
	var forward = -transform.basis.z.normalized()
	var right = transform.basis.x.normalized()

	if Input.is_action_pressed("move_forward"):
		input_vector += forward
	if Input.is_action_pressed("move_left"):
		input_vector -= right
	if Input.is_action_pressed("move_backward"):
		input_vector -= forward
	if Input.is_action_pressed("move_right"):
		input_vector += right

	if input_vector.length() > 0.0:
		input_vector = input_vector.normalized()

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity

	var sprinting = Input.is_action_pressed("sprint")

	if is_on_floor():
		var speed = sprint_speed if sprinting else move_speed

		var target_velocity = input_vector * speed
		velocity.x = lerp(velocity.x, target_velocity.x, 0.1)
		velocity.z = lerp(velocity.z, target_velocity.z, 0.1)
	else:
		velocity.y += gravity * delta

	move_and_slide()

	is_moving = velocity.length() > 0.3

	# CharacterBody to RigidBody interaction
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody3D:
			collider.apply_central_impulse(-collision.get_normal())

	viewpunch_target = viewpunch_target.lerp(Vector3.ZERO, 0.1)
	_viewpunch = _viewpunch.lerp(viewpunch_target, 0.6)

	var lerp_speed = 0.15

	var camera_tx: Transform3D = camera_position.global_transform
	if not is_zero_approx(_viewpunch.length()):
		camera_tx = camera_tx.rotated_local(_viewpunch.normalized(), _viewpunch.length())
	if Input.is_action_pressed("lean_left"):
		camera_tx = camera_tx.translated_local(Vector3(-0.5, 0.0, 0))
		camera_tx = camera_tx.rotated_local(Vector3(0, 0, 1), 0.1)
		lerp_speed = 0.1
	elif Input.is_action_pressed("lean_right"):
		camera_tx = camera_tx.translated_local(Vector3(0.5, 0.0, 0))
		camera_tx = camera_tx.rotated_local(Vector3(0, 0, 1), -0.1)
		lerp_speed = 0.1
	camera_tx = camera_tx.rotated_local(Vector3.UP, gun_controller.recoil / 10)
	camera.global_transform = camera.global_transform.interpolate_with(camera_tx, lerp_speed)

	camera_target_rotation.x -= mouse_delta.y * 0.004
	camera_target_rotation.y -= mouse_delta.x * 0.004
	camera_target_rotation.x = clampf(camera_target_rotation.x, -1.5, 1.5)
	camera_position.rotation.x = lerp(camera_position.rotation.x, camera_target_rotation.x, 0.4)

	var target_basis := Basis.IDENTITY.rotated(Vector3(0, 1, 0), camera_target_rotation.y)
	basis = basis.slerp(target_basis, 0.4)

	var viewbob_sine = sin((PI * viewbob_time) / 30) * viewbob_amplitude / 2 * PI

	viewpunch_target += Vector3(
		randf_range(-ambient_viewbob, ambient_viewbob),
		randf_range(-ambient_viewbob, ambient_viewbob),
		randf_range(-ambient_viewbob, ambient_viewbob)
	) * lerp(10.0, 1.0, health_percent)

	gun_controller.punch_target += Vector3(
		randf_range(-ambient_viewbob, ambient_viewbob),
		randf_range(-ambient_viewbob, ambient_viewbob),
		randf_range(-ambient_viewbob, ambient_viewbob)
	) * lerp(3.0, 0.25, health_percent + hand_shakiness)

	hand_shakiness = lerp(hand_shakiness, 0.0, 0.1)

	if input_vector.length() > 0.1:
		viewbob_time += viewbob_frequency * (velocity.length() / 4)
		camera_position.position.y = viewbob_sine + 0.7
		gun_controller.rotation.x += viewbob_sine / 4
		if viewbob_sine < -0.015 and last_viewbob_sine > -0.015:
			if is_on_floor():
				GLOBAL.playsound3d(GLOBAL.randsfx(SFX_FOOTSTEP[get_footstep_material()]), global_position, 0.05)
				if step_side:
					viewpunch_target += Vector3(-0.025, 0, 0.025)
				else:
					viewpunch_target += Vector3(-0.025, 0, -0.025)
				step_side = !step_side
	else:
		viewbob_time = lerp(viewbob_time, 0.0, 0.1)

	if is_on_floor() and not was_on_floor:
		GLOBAL.playsound3d(GLOBAL.randsfx(SFX_FOOTSTEP[get_footstep_material()]), global_position, 0.05)
	if was_moving and not is_moving:
		GLOBAL.playsound3d(GLOBAL.randsfx(SFX_FOOTSTEP[get_footstep_material()]), global_position, 0.05)

	var target_tx: Transform3D
	if Input.is_action_pressed("rmb"):
		target_tx = camera_position.global_transform.translated_local(Vector3(0, -0.173, -0.5))
	elif not Input.is_action_pressed("lean_left") and not Input.is_action_pressed("lean_right"):
		target_tx = camera_position.global_transform.translated_local(Vector3(0.1, -0.3, -0.2))
	else:
		target_tx = camera_position.global_transform.translated_local(Vector3(0.0, -0.3, -0.2))
	if Input.is_action_pressed("lean_left"):
		target_tx = target_tx.translated_local(Vector3(-0.48, 0.0, 0))
		target_tx = target_tx.rotated_local(Vector3(0, 0, 1), 0.1)
	elif Input.is_action_pressed("lean_right"):
		target_tx = target_tx.translated_local(Vector3(0.48, 0.0, 0))
		target_tx = target_tx.rotated_local(Vector3(0, 0, 1), -0.1)
	elif not Input.is_action_pressed("rmb") and not gun_controller.reloading and not gun_controller.inspecting:
		target_tx = camera_position.global_transform.translated_local(Vector3(0.1, -0.3, -0.2))
		target_tx = target_tx.rotated_local(Vector3(1, 0, 0), -0.3)
		target_tx = target_tx.rotated_local(Vector3(0, 0, 1), 0.5)
	if gun_controller.reloading:
		if Input.is_action_pressed("rmb"):
			target_tx = target_tx.translated_local(Vector3(0.05, 0.0, 0.0))
			target_tx = target_tx.rotated_local(Vector3(0, 1, 0), 0.1)
			target_tx = target_tx.rotated_local(Vector3(1, 0, 0), 0.05)
		else:
			target_tx = target_tx.translated_local(Vector3(0.25, 0.15, -0.25))
			target_tx = target_tx.rotated_local(Vector3(0, 1, 0), 1.0)
			target_tx = target_tx.rotated_local(Vector3(1, 0, 0), 0.25)
	if gun_controller.inspecting:
			target_tx = target_tx.translated_local(Vector3(-0.1, 0.25, -0.25))
			target_tx = target_tx.rotated_local(Vector3(0, 1, 0), 1.55)
			lerp_speed = 0.2
	gun_controller.global_transform = gun_controller.global_transform.interpolate_with(target_tx, lerp_speed) 

	gun_controller.global_position += velocity / 500
	gun_controller.rotation.x -= mouse_delta.y / 800
	gun_controller.rotation.y -= mouse_delta.x / 800

	gun_controller.rotation += gun_controller.punch

	if gun_controller.get_child_count() > gun_controller.base_child_count:
		gun = gun_controller.get_child(gun_controller.base_child_count)

	gun_controller.punch_target = gun_controller.punch_target.lerp(Vector3.ZERO, 0.1)
	gun_controller.punch = gun_controller.punch.lerp(gun_controller.punch_target, 0.6)

	if gun:
		gun.rotation.x = gun_controller.recoil
	gun_controller.rotation.x += gun_controller.recoil / 2
	if gun:
		gun_controller.recoil = lerp(gun_controller.recoil, 0.0, gun.recoil_recovery)
	else:
		gun_controller.recoil = lerp(gun_controller.recoil, 0.0, 0.4)

	if Input.is_action_just_pressed("reload") and not gun_controller.reloading and not gun_controller.inspecting:
		if gun != null:
			var can_reload
			if gun.plus_one:
				can_reload = gun.ammo < gun.max_ammo + 1
			else:
				can_reload = gun.ammo < gun.max_ammo
			if can_reload:
				can_reload = reserve_ammo > 0
				if can_reload:
					gun.reload()
					if anim.has_animation("reload_" + GunManager.GUNS[equipped_gun]["id"]):
						reload_anim("reload")
					await gun.reload_finished

	if Input.is_action_just_pressed("inspect"):
		gun_controller.inspecting = !gun_controller.inspecting
		if gun_controller.inspecting:
			GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_open.wav"), 1.0, 1.0, "UI")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_close.wav"), 1.0, 1.0, "UI")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.is_action_pressed("lmb") and not gun_controller.reloading and not gun_controller.inspecting:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if gun != null:
				trigger_time += delta
				if trigger_time > gun.trigger_time and not trigger_pulled:
					GLOBAL.playsound3d(preload("res://assets/audio/sfx/weapons/trigger_down.ogg"), global_position, 0.1, randf_range(0.85, 0.95))
				if trigger_time > gun.trigger_time and not shot:
					trigger_pulled = true
					if not gun.full_auto:
						shot = true
					if gun.ammo > 0:
						camera_target_rotation.x += gun.recoil_amount
						gun_controller.recoil += gun.recoil_amount
						gun_controller.punch.x += gun.gunpunch
						hand_shakiness += 1.0
						gun_controller.punch_target += Vector3(
							randf_range(-0.01, 0.01),
							randf_range(-0.01, 0.01),
							randf_range(-0.025, 0.025)
						)
						if gun != null:
							if gun.has_method("shoot"):
								gun.shoot()
						trigger_time = 0.0

	if Input.is_action_just_released("lmb"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if gun != null:
				trigger_pulled = false
				shot = false
				trigger_time = 0.0
				GLOBAL.playsound3d(preload("res://assets/audio/sfx/weapons/trigger_down.ogg"), global_position, 0.05, randf_range(0.95, 1.05))

	mouse_delta = Vector2.ZERO
	last_viewbob_sine = viewbob_sine
	was_on_floor = is_on_floor()
	was_moving = is_moving

func get_footstep_material() -> StringName:
	if foot_ray.is_colliding():
		var collider = foot_ray.get_collider()
		if collider:
			if collider.has_meta("material"):
				return collider.get_meta("material")
	return "metal"

func give_gun(target_gun: String):
	if gun_controller.get_child_count() > gun_controller.base_child_count:
		if gun_controller.get_child(gun_controller.base_child_count):
			gun_controller.get_child(gun_controller.base_child_count).queue_free()
	gun = null
	if target_gun != "":
		var path = GunManager.GUNS[target_gun]["scene_path"]
		gun = load(path).instantiate()
		equipped_gun = target_gun
		gun_controller.add_child(gun)

func give_rand_gun():
	var guns = GunManager.GUNS.keys()
	give_gun(guns[randi_range(0, guns.size() - 1)])

func _hit_by_bullet(hit):
	GLOBAL.playsound(GLOBAL.randsfx(SFX_FLESH_HIT), 5.0, 1.0, "Master")
	viewpunch_target += Vector3(
		randf_range(-1, 1),
		randf_range(-1, 1),
		randf_range(-1, 1)
	) / 2
	health -= randf_range(0.01, 0.05)
	if hit == $Head:
		GLOBAL.playsound(GLOBAL.randsfx(SFX_FLESH_HIT), 50.0, 1.0, "Master")
		hud.get_node("Blackout").modulate.a = 1.0
		await get_tree().create_timer(0.05).timeout
		health = 0.0
		if health <= 0.0:
			GLOBAL.player_fatal_hit = "head"
	elif hit == $Body:
		if health <= 0.0:
			GLOBAL.player_fatal_hit = "body"

func reload_anim(animation: String):
	anim.play(animation + "_" + GunManager.GUNS[equipped_gun]["id"])
