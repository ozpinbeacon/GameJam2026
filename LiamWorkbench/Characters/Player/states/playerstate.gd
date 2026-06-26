class_name PlayerState extends State

const IDLE = "Idle"
const WALKING = "Walking"
const RUNNING = "Running"
const CROUCHING = "Crouching"
const JUMPING = "Jumping"
const FALLING = "Falling"

var player: Player

func input(event) -> void:
	pass

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null)
