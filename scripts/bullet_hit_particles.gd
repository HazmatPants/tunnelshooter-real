extends GPUParticles3D

@onready var decal = $Decal

func _ready() -> void:
	randomize()
	decal.texture_normal.noise = decal.texture_normal.noise.duplicate()
	decal.texture_normal.noise.seed = randi()
