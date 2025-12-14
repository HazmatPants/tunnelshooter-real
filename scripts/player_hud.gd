extends CanvasLayer

@onready var crosshair = $Crosshair
@onready var reload_progress = $Crosshair/TextureRect/ReloadProgress
var crosshair_size: float = 512.0

func _process(_delta: float) -> void:
	var inspecting = GLOBAL.player.gun_controller.inspecting
	if GLOBAL.player.gun != null:
		var gun = GLOBAL.player.gun
		var title_text := ""
		var desc_text := ""

		match GLOBAL.player.equipped_gun:
			GLOBAL.GUNS.GI_MK_1:
				title_text = "GI Mk. 1"
				desc_text = "A .45 caliber handgun designed by Grigga Industries. Higher recoil compared to 9x19mm, but more powerful and has a light trigger for high fire rate. Features glow-in-the-dark iron sights for low-light encounters.\n\n"
				desc_text += "Caliber: .45 GI\n"
			GLOBAL.GUNS.OGON_50:
				title_text = "Ogon .50"
				desc_text = "A powerful .50 AE handgun designed by Ogon. Has a lot of kick and a heavy trigger, but extreme stopping power.\n\n"
				desc_text += "Caliber: .50 AE\n"
			GLOBAL.GUNS.GI_MK_1_AUTO:
				title_text = "GI Mk. 1 Auto Mod"
				desc_text = "A modified GI Mk. 1 handgun with the disconnector removed, allowing full auto fire. Has a large muzzle brake to help with the immense recoil.\n\n"
				desc_text += "Caliber: .45 GI\n"
			GLOBAL.GUNS.OGON_50_AUTO:
				title_text = "Ogon .50 Auto Mod"
				desc_text = "\"This was a mistake.\"\n\nAn absurd modification of the Ogon .50 with the disconnector removed, allowing full auto fire. Fitted with an extended mag and a foregrip in a futile attempt at recoil control.\n\n"
				desc_text += "Caliber: .50 AE\n"

		desc_text += "Trigger travel time: %sms\n" % int(gun.trigger_time * 1000)
		desc_text += "Fire rate: ~%s RPM\n" % int(60.0 / gun.trigger_time)
		desc_text += "Capacity: %s + 1\n" % gun.max_ammo
		desc_text += "Recoil: %.1f°\n" % rad_to_deg(gun.recoil_amount)

		$Inspect/VBoxContainer/Title.text = title_text
		$Inspect/VBoxContainer/Description.text = desc_text
	$Inspect.visible = inspecting
	if inspecting:
		$Inspect/Background.modulate.a = lerp($Inspect/Background.modulate.a, 1.0, 0.1)
	else:
		$Inspect/Background.modulate.a = lerp($Inspect/Background.modulate.a, 0.0, 0.1)
	var crosshair_modulate_a: float = 1.0
	if GLOBAL.player.gun:
		var ray: RayCast3D = GLOBAL.player.gun.ray
		var ray_point := Vector3.ZERO
		if ray.is_colliding():
			crosshair_modulate_a = 0.8
			ray_point = ray.get_collision_point()
		else:
			crosshair_modulate_a = 0.1
			ray_point = ray.to_global(ray.target_position)
		var crosshair_target = GLOBAL.player.camera.unproject_position(ray_point)
		if GLOBAL.player.gun_controller.reloading:
			crosshair_target = DisplayServer.window_get_size(0) / 2
		crosshair.global_position = crosshair.global_position.lerp(crosshair_target, 0.2)


	if Input.is_action_pressed("rmb") and not GLOBAL.player.gun_controller.reloading:
		crosshair_modulate_a = 0.0

	var crosshair_tex = $Crosshair/TextureRect

	crosshair_size = 512.0 + (GLOBAL.player.gun_controller.recoil * 2e4)
	crosshair_size = lerp(crosshair_size, 512.0, 0.05)

	crosshair_tex.size = crosshair_tex.size.lerp(Vector2.ONE * crosshair_size, 0.05)
	crosshair_tex.position = -crosshair_tex.size / 2
	crosshair_tex.pivot_offset = crosshair_tex.size / 2

	reload_progress.scale = crosshair_tex.size / 512

	crosshair.modulate.a = lerp(crosshair.modulate.a, crosshair_modulate_a, 0.2)
