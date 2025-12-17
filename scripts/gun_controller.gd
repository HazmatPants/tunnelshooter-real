extends Node3D

@onready var bump_ray: RayCast3D = $BumpRay

@export var ricochet_threshold: float = 0.6

const MAX_DISTANCE := 5000.0
const MAX_RICOCHETS := 2

var recoil: float = 0.0
var punch_target := Vector3.ZERO

var punch := Vector3.ZERO

var reloading: bool = false
var inspecting: bool = false

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

var distance: float = 0.0
func _physics_process(_delta: float) -> void:
	if not GLOBAL.player: return
	bump_ray.global_transform = global_transform.translated_local(Vector3(0, 0.1, 0.055))
	if GLOBAL.player.gun:
		if bump_ray.is_colliding():
			var hit_point = bump_ray.get_collision_point()
			distance = global_position.distance_to(hit_point)
		else:
			distance = lerp(distance, 0.6, 0.1)
		GLOBAL.player.gun.position.z = 0.6 - distance

func shoot(ray, bullet_energy, penetration_power):
	var origin = ray.global_position
	var direction = -ray.global_transform.basis.z.normalized()
	var energy = bullet_energy

	while energy > 0:
		if not get_tree(): break
		var to = origin + direction * MAX_DISTANCE
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
	casing.type = GunManager.GUNS[GLOBAL.player.equipped_gun]["caliber_id"]
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
