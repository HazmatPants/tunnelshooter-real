extends Node

const MOD_DIRECTORY = "user://mods"

var loaded_mods = []

signal mods_loaded

func _ready() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(MOD_DIRECTORY):
		dir.make_dir(MOD_DIRECTORY)
		push_warning("mod directory not found, created it.")
	if not FileAccess.file_exists("user://mods/README.txt"):
		push_warning("readme file not found, created it.")
		var file = FileAccess.open("user://mods/README.txt", FileAccess.WRITE)
		var readme = "the mod loader will ignore directories that begin with `.`\n\n"
		readme += "check https://github.com/HazmatPants/tunnelshooter-real-mod-example for an example of how to make a mod"
		file.store_string(readme)
		file.close()

	await load_mods()
	mods_loaded.emit()

func load_mods():
	for mod in DirAccess.get_directories_at(MOD_DIRECTORY):
		if mod.begins_with(".") or mod == "README.txt":
			return
		var mod_path = MOD_DIRECTORY.path_join(mod)
		load_mod(mod_path)

	loaded_mods.sort_custom(func(a, b):
		return a.priority > b.priority
	)

	print("Loaded %s mods" % loaded_mods.size())

func load_mod(mod_path: String):
	var manifest_path = mod_path.path_join("manifest.json")
	if FileAccess.file_exists(manifest_path):
		var file_contents = FileAccess.open(manifest_path, FileAccess.READ).get_as_text(true)
		var manifest = JSON.parse_string(file_contents)
		if manifest is Dictionary:
			if manifest.has("id"):
				var mod_id = manifest["id"]

				var mod_main = mod_path.path_join(manifest.get("main", "main.gd"))
				var script = load(mod_main)

				if not script:
					push_error("Failed to load mod script: ", mod_main)
					return

				var mod = script.new()

				mod.mod_name = manifest["name"]
				mod.author = manifest["author"]
				mod.description = manifest["description"]
				mod.priority = manifest["priority"]
				mod.main = manifest["main"]

				if mod.has_method("_mod_init"):
					mod._mod_init(mod_id, mod_path)

				add_child(mod)
				mod.on_load()
				loaded_mods.append(mod)
		else:
			push_error("mod '%s' failed to parse" % mod_path)
			return

func call_hook(hook: String, args: Array=[]):
	for mod in loaded_mods:
		if mod.has_method(hook):
			mod.callv(hook, args)
