extends CanvasLayer

@onready var crosshair = $Crosshair
var crosshair_size: float = 512.0

var sine_time: float = 0.0

func _process(delta: float) -> void:
	if not GLOBAL.player: return
	var inspecting = GLOBAL.player.gun_controller.inspecting
	if GLOBAL.player.gun != null:
		var gun = GLOBAL.player.gun
		var equipped_gun = GLOBAL.player.equipped_gun
		var title_text := ""
		var desc_text := ""

		title_text = GunManager.GUNS[equipped_gun]["name"]
		desc_text = GunManager.GUNS[equipped_gun]["description"]

		desc_text += "Caliber: %s\n" % GunManager.ROUNDS[GunManager.GUNS[equipped_gun]["caliber_id"]]["full_name"]
		desc_text += "Trigger travel time: %sms\n" % int(gun.trigger_time * 1000)
		desc_text += "Fire rate: ~%s RPM\n" % int(60.0 / gun.trigger_time)
		desc_text += "Capacity: %s" % gun.max_ammo
		desc_text += " + 1\n" if gun.plus_one else "\n"
		desc_text += "Recoil: %.1f°\n" % rad_to_deg(gun.recoil_amount)

		$Inspect/VBoxContainer/Title.text = title_text
		$Inspect/VBoxContainer/Description.text = desc_text
	$Inspect.visible = inspecting
	if inspecting:
		$Inspect/Background.modulate.a = lerp($Inspect/Background.modulate.a, 1.0, 0.1)
	else:
		$Inspect/Background.modulate.a = lerp($Inspect/Background.modulate.a, 0.0, 0.1)
	var crosshair_alpha: float = 1.0
	if GLOBAL.player.gun:
		var ray: RayCast3D = GLOBAL.player.gun.ray
		var ray_point := Vector3.ZERO
		if ray.is_colliding():
			crosshair_alpha = 0.8
			ray_point = ray.get_collision_point()
		else:
			crosshair_alpha = 0.1
			ray_point = ray.to_global(ray.target_position)
		var crosshair_target = GLOBAL.player.camera.unproject_position(ray_point)
		if GLOBAL.player.gun_controller.reloading:
			crosshair_target = DisplayServer.window_get_size(0) / 2
		crosshair.global_position = crosshair.global_position.lerp(crosshair_target, 0.2)


	if Input.is_action_pressed("rmb") and not GLOBAL.player.gun_controller.reloading:
		crosshair_alpha = 0.0

	var crosshair_tex = $Crosshair/TextureRect

	crosshair_size = 512.0 + (GLOBAL.player.gun_controller.recoil * 2e4)
	crosshair_size = lerp(crosshair_size, 512.0, 0.05)

	crosshair_tex.size = crosshair_tex.size.lerp(Vector2.ONE * crosshair_size, 0.05)
	crosshair_tex.position = -crosshair_tex.size / 2
	crosshair_tex.pivot_offset = crosshair_tex.size / 2

	crosshair.modulate.a = lerp(crosshair.modulate.a, crosshair_alpha, 0.2)

	if GLOBAL.player.reserve_ammo > 922339203600000000:
		$ReserveLabel.text = "Reserve: INF"
	else:
		$ReserveLabel.text = "Reserve: %s" % GLOBAL.player.reserve_ammo
	if GLOBAL.player.gun:
		$AmmoLabel.text = "Ammo: %s" % GLOBAL.player.gun.ammo

	sine_time += delta

	var pain_sine = (sin(sine_time * 4.0) + 1.5) * 0.5
	pain_sine = lerp(0.4, 1.0, pain_sine)
	var mod = 1.0 - GLOBAL.player.health_percent

	$DamageOverlay.texture.gradient.set_offset(0, 1.0 - (pain_sine * mod))
	$DamageOverlay.modulate.a = 1.0 - GLOBAL.player.health_percent
	$Blackout.modulate.a = lerp($Blackout.modulate.a, 1.0 - GLOBAL.player.health_percent, 0.05)

func show_notif(text: String, duration: float=3.0):
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var tween = label.create_tween()
	tween.tween_interval(duration)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.finished.connect(label.queue_free)
	
	$NotifContainer.add_child(label)
