extends Node

@export var debug: bool = false

var player: CharacterBody3D = null
var player_fatal_hit := ""

signal initialized

func _ready() -> void:
	await GunManager.init()
	await init()
	await ModManager.mods_loaded

func init():
	if is_inside_tree():
		player = null
		player = get_tree().current_scene.get_node_or_null("Player")
	await player.ready
	initialized.emit()

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

func show_notif(text: String, duration: float=3.0):
	player.hud.show_notif(text, duration)

func switch_to_scene(scene: PackedScene):
	get_tree().change_scene_to_packed(scene)
