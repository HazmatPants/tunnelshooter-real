extends Node

@onready var limbs = {
	"Head": $"../Head",
	"Thorax": $"../Thorax",
	"Abdomen": $"../Abdomen",
}

@export var blood_regen_rate: float = 0.0005
@export var blood_clot_rate: float = 0.00001

var consciousness: float = 1.0
var brain_health: float = 1.0
var brain_o2: float = 1.0
var blood_volume: float = 5.0
var blood_o2: float = 1.0

var bleeding_rate: float = 0.0

var beat_timer: float = 0.0
var heart_rate: float = 80.0

func _process(delta: float) -> void:
	beat_timer += delta
	if beat_timer > 60 / heart_rate:
		GLOBAL.playsound(preload("res://assets/audio/sfx/player/heartthump.ogg"), 0.1, 1.0, "Master", randf_range(0.0, 0.05))
		blood_o2 += randf() / 10
		beat_timer = 0.0
	bleeding_rate = get_limb_total("bleed_amount")
	blood_volume -= bleeding_rate * delta
	if blood_volume < 5.0:
		blood_volume += blood_regen_rate * delta

	blood_o2 = clampf(blood_o2, 0.0, blood_volume / 5.0)

	brain_o2 = lerp(brain_o2, blood_o2, 0.005)
	if brain_o2 < 0.7:
		brain_health = lerp(brain_health, brain_o2, 0.001)
	consciousness = clampf(consciousness, 0.0, brain_health)
	brain_health = clampf(brain_health, 0.0, 1.0)
	brain_o2 = clampf(brain_o2, 0.0, 1.0)

func _hit_by_bullet(hit):
	if hit == owner: return
	limbs[hit.name].skin_health -= randf_range(0.01, 0.05)
	limbs[hit.name].muscle_health -= randf_range(0.05, 0.1)
	limbs[hit.name].bleed_amount += randf_range(0.001, 0.005)

func get_limb_all(property: String) -> Dictionary:
	var all := {}
	for limb: String in limbs.keys():
		all[limb] = limbs[limb].get(property)
	return all

func get_limb_total(property: String) -> float:
	var total: float = 0.0
	for limb: String in limbs.keys():
		total += limbs[limb].get(property)
	return total
