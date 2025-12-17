extends Node

var GUNS = {}
var ROUNDS = {}

func init():
	register_round("45gi", ".45 GI", ".45 Grigga Industries")
	register_round("50ae", ".50 AE", ".50 Action Express")
	register_round("9mm", "9x19mm", "9x19mm Parabellum")

	register_gun(
		"gi_mk_1",
		"GI Mk. 1",
		"45gi",
		"res://scenes/gi_mk_1.tscn",
		"A .45 caliber handgun designed by Grigga Industries. Higher recoil compared to 9x19mm, but more powerful and has a light trigger for high fire rate. Features glow-in-the-dark iron sights for low-light encounters.\n\n"
	)
	register_gun(
		"gi_mk_1_auto",
		"GI Mk. 1 Auto Mod",
		"45gi",
		"res://scenes/gi_mk_1_auto.tscn",
		"A modified GI Mk. 1 handgun with the disconnector removed, allowing full auto fire. Has a large muzzle brake to help with the immense recoil.\n\n"
	)
	register_gun(
		"ogon50",
		"Ogon .50",
		"50ae",
		"res://scenes/ogon50.tscn",
		"A powerful .50 AE handgun designed by Ogon Military Industries. Has a lot of kick and a heavy trigger, but extreme stopping power.\n\n"
	)
	register_gun(
		"ogon50_auto",
		"Ogon .50 Auto Mod",
		"50ae",
		"res://scenes/ogon50_auto.tscn",
		"\"This was a mistake.\"\n\nAn absurd modification of the Ogon .50 with the disconnector removed, allowing full auto fire. Fitted with an extended mag and a foregrip in a futile attempt at recoil control.\n\n"
	)
	register_gun(
		"sz19",
		"SZ 19",
		"9mm",
		"res://scenes/sz19.tscn",
		"A 9x19mm top-loading handgun designed by Seeg Zauer.\n\n"
	)
	register_gun(
		"sz19_auto",
		"SZ 19 Auto Mod",
		"9mm",
		"res://scenes/sz19_auto.tscn",
		"A modifed SZ 19 with the disconnector removed, allowing full-auto fire. Due to the extended mag, it requires multiple clips to reload from empty.\n\n"
	)

	print("Registered %s guns" % GUNS.keys().size())

func register_round(
	round_id: String,
	round_name: String,
	round_full_name: String="",
	):
		ROUNDS[round_id] = {}
		ROUNDS[round_id]["name"] = round_name
		if round_full_name:
			ROUNDS[round_id]["full_name"] = round_full_name
		else:
			ROUNDS[round_id]["full_name"] = round_name

func register_gun(
	gun_id: String,
	gun_name: String,
	caliber_id: String,
	scene_path: String,
	description: String="",
	manufacturer: String="unknown",
	):
		GUNS[gun_id] = {}
		GUNS[gun_id]["id"] = gun_id
		GUNS[gun_id]["name"] = gun_name
		GUNS[gun_id]["caliber_id"] = caliber_id
		if not ROUNDS.has(caliber_id):
			push_error("gun round '%s' not found in round registry!" % caliber_id)
			breakpoint
		GUNS[gun_id]["scene_path"] = scene_path
		if not ResourceLoader.exists(scene_path):
			push_error("gun scene not found at path '%s'!" % scene_path)
			breakpoint
		GUNS[gun_id]["description"] = description
		GUNS[gun_id]["manufacturer"] = manufacturer

func get_dict_all(dict: Dictionary, key: String) -> Array:
	var result := []
	for i in dict.keys():
		if dict[i].has(key):
			result.append(dict[i][key])
	return result
