extends Node3D

@onready var light = $SpotLight3D

# Torch on/off functionality
var lantern_status: bool = true

# Random number generator for flame flicker effect
var rng: RandomNumberGenerator

func _ready() -> void:
	# Initialise random number generator
	self.rng = RandomNumberGenerator.new()

func _physics_process(delta: float) -> void:
	# Get a random number from 1 to 3 and lerp the light's energy to that number
	var rng_n = rng.randf_range(1, 3)
	light.light_energy = lerp(light.light_energy, rng_n, 3 * delta)

func toggle_lantern() -> void:
	if lantern_status:
		light.hide()
		lantern_status = false
	elif not lantern_status:
		light.show()
		lantern_status = true
		
