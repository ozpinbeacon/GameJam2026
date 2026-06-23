extends Node3D

const TRIPPY_WET_GROUND_MATERIAL = preload("uid://b1reqk55gfijg")
const TRIPPY_BREATHE_WET_GROUND_MATERIAL = preload("uid://b6gtdtjeh4vvf")


@onready var maze_ground_mesh: MeshInstance3D = $ProceduralHedge/MazeGround

var default_heightmap_scale: float = 0.0
var max_trippy_wet_value: float = 0.0
var min_trippy_wet_value: float = -7.046
var trippy_down_half_cycle_time: float = 2.0
var trippy_up_half_cycle_time: float = 4.0

var max_trippy_breathe_value: float = 2.3
var min_trippy_breathe_value: float = -2.3


var trippy_tween: Tween

@export var activate_trippy_floor: bool = false:##MAKE SURE THIS IS OFF BEROFRE STARTING THE GAME
	set(value):
		activate_trippy_floor = value
		if value:
			kill_trippy_breathing_floor()
			activate_trippy_wet_floor_FX()
		else:
			kill_trippy_wet_floor()

@export var activate_breathing_floor: bool = false:##MAKE SURE THIS IS OFF BEROFRE STARTING THE GAME
	set(value):
		activate_breathing_floor = value
		if value:
			kill_trippy_wet_floor()
			activate_trippy_breathing_floor_FX()
		else:
			kill_trippy_breathing_floor()



func _ready() -> void:
	if activate_trippy_floor:
		activate_trippy_wet_floor_FX()


## TRIPPY WET FX ##
func activate_trippy_wet_floor_FX() -> void:
	if maze_ground_mesh.get_surface_override_material(0) != TRIPPY_WET_GROUND_MATERIAL:
		maze_ground_mesh.set_surface_override_material(0, TRIPPY_WET_GROUND_MATERIAL)
	
	# Kill any existing tween first so they don't stack
	if trippy_tween and trippy_tween.is_valid():
		trippy_tween.kill()
	
	# Give birth to a new tween
	trippy_tween = get_tree().create_tween()
	trippy_tween.set_loops() # loops the tween forever
	
	# Set the trans and ease of the tween
	trippy_tween.set_trans(Tween.TRANS_CUBIC)
	trippy_tween.set_ease(Tween.EASE_OUT)

	# Up to max with a wobbly elastic ease
	trippy_tween.tween_property(
		maze_ground_mesh, 
		"material_override:heightmap_scale", 
		max_trippy_wet_value, 
		trippy_up_half_cycle_time
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# Down to min with a different bouncy ease for variation
	trippy_tween.tween_property(
		maze_ground_mesh, 
		"material_override:heightmap_scale", 
		min_trippy_wet_value, 
		trippy_down_half_cycle_time
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

func kill_trippy_wet_floor() -> void:
	if trippy_tween and trippy_tween.is_valid():
		trippy_tween.kill()
	if maze_ground_mesh.material_override:
		maze_ground_mesh.material_override.heightmap_scale = default_heightmap_scale



## BREATHING FX ##
func activate_trippy_breathing_floor_FX() -> void:
	if maze_ground_mesh.get_surface_override_material(0) != TRIPPY_WET_GROUND_MATERIAL:
		maze_ground_mesh.set_surface_override_material(0, TRIPPY_WET_GROUND_MATERIAL)
	
	# Kill any existing tween first so they don't stack
	if trippy_tween and trippy_tween.is_valid():
		trippy_tween.kill()
	
	# Give birth to a new tween
	trippy_tween = get_tree().create_tween()
	trippy_tween.set_loops() # loops the tween forever
	
	# Set the trans and ease of the tween
	trippy_tween.set_trans(Tween.TRANS_CIRC)
	trippy_tween.set_ease(Tween.EASE_OUT)

	# Up to max with a wobbly elastic ease
	trippy_tween.tween_property(
		maze_ground_mesh, 
		"material_override:heightmap_scale", 
		max_trippy_wet_value, 
		trippy_up_half_cycle_time
		).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)

	# Down to min with a different bouncy ease for variation
	trippy_tween.tween_property(
		maze_ground_mesh, 
		"material_override:heightmap_scale", 
		min_trippy_wet_value, 
		trippy_down_half_cycle_time
		).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)


func kill_trippy_breathing_floor() -> void:
	if trippy_tween and trippy_tween.is_valid():
		trippy_tween.kill()

	if maze_ground_mesh.material_override:
		maze_ground_mesh.material_override.heightmap_scale = default_heightmap_scale
