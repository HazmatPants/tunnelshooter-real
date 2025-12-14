extends Node

enum GUNS {
	NONE,
	GI_MK_1,
	GI_MK_1_AUTO,
	OGON_50,
	OGON_50_AUTO,
	SZ_19,
	SZ_19_AUTO,
}

const GUN_SCENES = {
	GUNS.NONE: null,
	GUNS.GI_MK_1: "res://scenes/gi_mk_1.tscn",
	GUNS.GI_MK_1_AUTO: "res://scenes/gi_mk_1_auto.tscn",
	GUNS.OGON_50: "res://scenes/ogon50.tscn",
	GUNS.OGON_50_AUTO: "res://scenes/ogon50_auto.tscn",
	GUNS.SZ_19: "res://scenes/sz19.tscn",
	GUNS.SZ_19_AUTO: "res://scenes/sz19_auto.tscn",
}

const GUN_NAMES = {
	GUNS.NONE: "",
	GUNS.GI_MK_1: "GI Mk. 1",
	GUNS.GI_MK_1_AUTO: "GI Mk. 1 Auto Mod",
	GUNS.OGON_50: "Ogon .50",
	GUNS.OGON_50_AUTO: "Ogon .50 Auto Mod",
	GUNS.SZ_19: "SZ 19",
	GUNS.SZ_19_AUTO: "SZ 19 Auto Mod",
}

const GUN_DESCS = {
	GUNS.NONE: "",
	GUNS.GI_MK_1: "A .45 caliber handgun designed by Grigga Industries. Higher recoil compared to 9x19mm, but more powerful and has a light trigger for high fire rate. Features glow-in-the-dark iron sights for low-light encounters.\n\n",
	GUNS.OGON_50: "A powerful .50 AE handgun designed by Ogon Military Industries. Has a lot of kick and a heavy trigger, but extreme stopping power.\n\n",
	GUNS.GI_MK_1_AUTO: "A modified GI Mk. 1 handgun with the disconnector removed, allowing full auto fire. Has a large muzzle brake to help with the immense recoil.\n\n",
	GUNS.OGON_50_AUTO: "\"This was a mistake.\"\n\nAn absurd modification of the Ogon .50 with the disconnector removed, allowing full auto fire. Fitted with an extended mag and a foregrip in a futile attempt at recoil control.\n\n",
	GUNS.SZ_19: "A 9x19mm top-loading handgun designed by Seeg Zauer.\n\n",
	GUNS.SZ_19_AUTO: "A modifed SZ 19 with the disconnector removed, allowing full-auto fire. Due to the extended mag, it requires multiple clips to reload from empty.\n\n",

}

const GUN_CALS = {
	GUNS.NONE: "",
	GUNS.GI_MK_1: ".45 GI",
	GUNS.GI_MK_1_AUTO: ".45 GI",
	GUNS.OGON_50: ".50 AE",
	GUNS.OGON_50_AUTO: ".50 AE",
	GUNS.SZ_19: "9x19mm Parabellum",
	GUNS.SZ_19_AUTO: "9x19mm Parabellum",
}

var player: CharacterBody3D = null

func _ready() -> void:
	player = get_tree().current_scene.get_node_or_null("Player")

func playsound(stream: AudioStream, volume_linear: float=1.0, pitch_scale: float=1.0, bus: String="SFX"):
	var ap = AudioStreamPlayer.new()
	ap.stream = stream
	ap.volume_linear = volume_linear
	ap.pitch_scale = pitch_scale
	ap.autoplay = true
	ap.bus = bus
	get_tree().current_scene.add_child(ap)
	ap.finished.connect(ap.queue_free)

func playsound3d(stream: AudioStream, global_position: Vector3, volume_linear: float=1.0, pitch_scale: float=1.0, bus: String="SFX"):
	var ap = AudioStreamPlayer3D.new()
	ap.stream = stream
	ap.volume_linear = volume_linear
	ap.pitch_scale = pitch_scale
	ap.autoplay = true
	ap.bus = bus
	get_tree().current_scene.add_child(ap)
	ap.global_position = global_position
	ap.finished.connect(ap.queue_free)

func randsfx(sound_list: Array) -> AudioStream:
	return sound_list[randi_range(0, sound_list.size() - 1)]
