class_name BaseMod
extends Node

var mod_path: String
var mod_id: String
var mod_name: String
var author: String
var description: String
var priority: int
var main: String

func _ready() -> void:
	on_ready()

func _mod_init(_id, _path):
	mod_id = _id
	mod_path = _path

func load_ogg(base_path: String, file_path: String) -> AudioStreamOggVorbis:
	var stream := AudioStreamOggVorbis.load_from_file(base_path.path_join(file_path))
	return stream

func load_wav(base_path: String, file_path: String) -> AudioStreamWAV:
	var stream := AudioStreamWAV.load_from_file(base_path.path_join(file_path))
	return stream

func load_mp3(base_path: String, file_path: String) -> AudioStreamMP3:
	var stream := AudioStreamMP3.load_from_file(base_path.path_join(file_path))
	return stream

func load_image(base_path: String, file_path: String) -> Image:
	var image := Image.new()
	var err = image.load(base_path.path_join(file_path))
	if err != OK:
		push_error("Error loading image: ", error_string(err))
		
	return image

func load_script(base_path: String, file_path: String) -> Node:
	var node = Node.new()
	var script = load(base_path.path_join(file_path))
	node.set_script(script)
	add_child(node)
	return node

func on_load(): pass
func on_ready(): pass
func on_unload(): pass
