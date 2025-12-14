extends Node

enum GUNS {
	NONE,
	GI_MK_1,
	GI_MK_1_AUTO,
	OGON_50,
	OGON_50_AUTO,
	OGON_19
}

const GUN_SCENES = {
	GUNS.NONE: null,
	GUNS.GI_MK_1: "res://scenes/gi_mk_1.tscn",
	GUNS.GI_MK_1_AUTO: "res://scenes/gi_mk_1_auto.tscn",
	GUNS.OGON_50: "res://scenes/ogon50.tscn",
	GUNS.OGON_50_AUTO: "res://scenes/ogon50_auto.tscn",
	GUNS.OGON_19: "res://scenes/ogon19.tscn",
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
