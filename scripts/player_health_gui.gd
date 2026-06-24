extends Control

var health: Node

func _process(_delta: float) -> void:
	if GLOBAL.player:
		health = GLOBAL.player.health
	if health == null: return

	if Input.is_action_just_pressed("health"):
		visible = !visible

	if not visible: return

	get_element("BrainHealthLabel").text = "INT: %.1f%%" % [(health.brain_health / 1.0) * 100]
	get_element("BrainO2Label").text = "O2: %.1f%%\n" % [(health.brain_o2 / 1.0) * 100]
	get_element("BloodVolLabel").text = "VOL: %.1f%% (%.1fL)" % [(health.blood_volume / 5.0) * 100, health.blood_volume]
	get_element("BloodLossLabel").text = "LOSS: -%.2fL/min" % [abs(health.bleeding_rate * 60)]
	get_element("BloodO2Label").text = "O2: %.1f%%" % [(health.blood_o2 / 1.0) * 100]

func get_element(element: String) -> Control:
	return $Panel/VBoxContainer.get_node(element)
