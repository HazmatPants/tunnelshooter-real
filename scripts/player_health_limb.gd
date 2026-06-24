extends Area3D

var skin_health: float = 1.0
var muscle_health: float = 1.0
var bleed_amount: float = 0.0

var health: Node

func _process(delta: float) -> void:
	if GLOBAL.player:
		health = GLOBAL.player.health

	if bleed_amount > 0.0:
		bleed_amount -= health.blood_clot_rate * delta
