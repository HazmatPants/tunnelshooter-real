extends Node3D

@onready var ypivot = $YPivot
@onready var xpivot = $YPivot/XPivot
@onready var ap_alarm = $AlarmPlayer

@export var fire_rate: float = 0.2
@export var prefire_time: float = -0.33

var state = "idle"
var functional: bool = true

var idle_timer: float = 0.0
var shoot_timer: float = prefire_time
var forget_timer: float = 0.0
var vision_timer: float = 0.0

var target_position: Vector3
var target_rotation: Vector3

var saw_player: bool = false
var sees_player: bool = false

const sfx_shoot = preload("res://assets/audio/sfx/weapons/caliber/45_crack.wav")
const sfx_crack = preload("res://assets/audio/sfx/weapons/caliber/50_shoot.wav")

func _process(delta: float) -> void:
	var led_energy = $Light.mesh.material.emission_energy_multiplier
	$Light.mesh.material.emission_energy_multiplier = lerp(led_energy, 0.0, 0.4)

	if not functional: 
		var light_energy = $YPivot/XPivot/MeshInstance3D2/SpotLight3D.light_energy
		$YPivot/XPivot/MeshInstance3D2/SpotLight3D.light_energy = lerp(light_energy, 0.0, 0.1)
		return

	if state == "shoot":
		target_position = GLOBAL.player.get_node("Body").global_position + (GLOBAL.player.velocity / 4)
		target_rotation = global_transform.looking_at(target_position).basis.get_euler()

	if state == "idle":
		ypivot.rotation.y = lerp_angle(ypivot.rotation.y, target_rotation.y, 0.01)
		xpivot.rotation.x = lerp_angle(xpivot.rotation.x, target_rotation.x, 0.01)
	elif state == "shoot":
		ypivot.rotation.y = lerp_angle(ypivot.rotation.y, target_rotation.y, 0.1)
		xpivot.rotation.x = lerp_angle(xpivot.rotation.x, target_rotation.x, 0.1)
	xpivot.rotation.x = clampf(xpivot.rotation.x, 0.0, deg_to_rad(90))

	if state == "idle":
		idle_timer += delta
		if idle_timer > 5.0:
			target_rotation = Vector3(
				randf_range(0.0, deg_to_rad(45)),
				randf_range(0.0, deg_to_rad(360)),
				0.0
			)
			idle_timer = 0.0
			shoot_timer = prefire_time

	vision_timer += delta
	if vision_timer > 0.25:
		sees_player = can_see_player(GLOBAL.player)
		$Light.mesh.material.emission_energy_multiplier = 10.0
		GLOBAL.playsound3d(preload("res://assets/audio/sfx/weapons/turret/turret_scan.wav"),
			global_position, 0.01
		)
		vision_timer = 0.0
	if sees_player:
		if not saw_player:
			ap_alarm.play()
		forget_timer = 0.0
		if state == "idle":
			state = "shoot"
			GLOBAL.playsound3d(preload("res://assets/audio/sfx/weapons/turret/turret_alert.wav"),
				global_position, 0.2
			)
		if state == "shoot":
			shoot_timer += delta
			if shoot_timer > fire_rate:
				shoot($YPivot/XPivot/RayCast3D, 25, 20)
				shoot_timer = 0.0
	else:
		if saw_player:
			ap_alarm.playing = false
		forget_timer += delta
		if state == "shoot" and forget_timer > 1.0:
			state = "idle"
			GLOBAL.playsound3d(preload("res://assets/audio/sfx/weapons/turret/turret_alert.wav"),
				global_position, 0.2
			)

	saw_player = sees_player

func place_decal(pos: Vector3, normal: Vector3, collider: Node3D):
	if not is_inside_tree(): return
	var particles: GPUParticles3D = preload("res://scenes/bullet_hit_particles.tscn").instantiate()
	get_tree().current_scene.add_child(particles)
	particles.draw_pass_1 = SphereMesh.new()
	particles.emitting = true

	particles.reparent(collider)

	for child in collider.get_children():
		if child is MeshInstance3D:
			var material = child.mesh.surface_get_material(0)
			if material:
				material.resource_local_to_scene = true
				material = material.duplicate()
				particles.draw_pass_1.surface_set_material(0, material)
				break

	var up := Vector3.UP
	if abs(normal.dot(up)) > 0.99:
		up = Vector3.FORWARD

	particles.global_position = pos
	particles.look_at(pos + normal, up)
	var tween = create_tween()
	tween.tween_interval(5.0)
	tween.tween_property(particles.decal, "texture_albedo:fill_to:x", 0.51, 1.0)
	tween.tween_property(particles.decal, "texture_albedo:fill_to:y", 0.51, 1.0)
	tween.finished.connect(particles.queue_free)

func shoot(ray, bullet_energy, penetration_power):
	var origin = ray.global_position
	var direction = -ray.global_transform.basis.z.normalized()
	var energy = bullet_energy

	GLOBAL.playsound3d(sfx_shoot, global_position, 5.0, randf_range(0.98, 1.02))
	GLOBAL.playsound3d(sfx_crack, global_position, randf_range(0.5, 1.0), randf_range(1.0, 1.25))
	var muzzflash = preload("res://scenes/muzzle_flash.tscn").instantiate()
	get_tree().current_scene.add_child(muzzflash)
	muzzflash.global_position = ray.global_position

	while energy > 0:
		if not get_tree(): break
		var to = origin + direction * 1000.0
		var query = PhysicsRayQueryParameters3D.create(origin, to)
		query.exclude = [self]
		query.collide_with_areas = true

		var hit = get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty():
			break

		var hit_pos = hit.position
		var normal = hit.normal
		var collider = hit.collider

		# Damage
		if collider:
			if collider.owner.has_method("_hit_by_bullet"):
				collider.owner._hit_by_bullet(collider)
			if collider.has_method("_hit_by_bullet"):
				collider._hit_by_bullet(collider)

			place_decal(hit_pos, normal, collider)

			var thickness = get_penetration_thickness(hit_pos, direction, collider)

			var energy_cost = thickness * 10

			if GLOBAL.debug:
				print("Bullet hit:")
				print("	Energy cost: ", energy_cost)
				print("	Bullet energy: ", energy + penetration_power)
				print("	Hit Node: ", collider)

			if energy + penetration_power > energy_cost:
				# Penetrate
				if GLOBAL.debug:
					print("	penetrated")
				energy -= energy_cost
				origin = hit_pos + direction * (thickness + 0.5)
				continue

		# Bullet stopped
		break

func get_penetration_thickness(
	entry_pos: Vector3,
	direction: Vector3,
	collider: Object
) -> float:
	var step := 0.05
	var max_distance := 5.0

	var traveled := 0.0
	var pos := entry_pos + direction * step

	while traveled < max_distance:
		if not is_inside_tree(): break
		var query = PhysicsRayQueryParameters3D.create(
			pos,
			pos + direction * step
		)
		query.hit_from_inside = true
		query.exclude = []

		var hit = get_world_3d().direct_space_state.intersect_ray(query)

		if hit.is_empty() or hit.collider != collider:
			return traveled

		traveled += step
		pos += direction * step

	return INF

func spawn_casing(tx: Transform3D, dir):
	var casing: RigidBody3D = preload("res://scenes/bullet_casing.tscn").instantiate()
	get_tree().current_scene.add_child(casing)
	casing.type = GLOBAL.GUN_CALS_INT[GLOBAL.player.equipped_gun]
	casing.global_position = tx.origin
	casing.global_rotation = tx.basis.get_euler()
	var c_vel: Vector3 = dir
	c_vel += Vector3(
		randf_range(-0.1, 0.1),
		randf_range(-0.1, 0.1),
		randf_range(-0.1, 0.1)
	)
	casing.angular_velocity += Vector3(
		randf_range(-1, 1),
		randf_range(-1, 1),
		randf_range(-1, 1)
	) * randf()
	casing.apply_central_impulse(c_vel * randf_range(5.0, 10.0))
	casing.casing_ready()

func can_see_player(player: Node3D) -> bool:
	var view_distance := 30.0
	var view_angle := 100.0

	var player_pos = player.global_position

	var to_player = player_pos - xpivot.global_position
	if to_player.length() > view_distance:
		return false

	var forward = -xpivot.global_transform.basis.z
	var dir = to_player.normalized()
	var dot = forward.dot(dir)

	var angle = rad_to_deg(acos(dot))
	if angle > (view_angle / 2):
		return false

	var query = PhysicsRayQueryParameters3D.create(xpivot.global_position, player_pos)
	query.exclude = [self]
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return true

	return result.collider.owner == player

func _hit_by_bullet(_hit):
	if functional:
		var tween = xpivot.create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(xpivot, "rotation:x", deg_to_rad(-25), 1.0)
	functional = false
