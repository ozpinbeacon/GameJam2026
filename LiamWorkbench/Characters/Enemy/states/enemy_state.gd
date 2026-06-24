class_name EnemyState extends State

const PATROLLING = "Patrolling"
const CHASING = "Chasing"
const ALERT = "Alert"
const INVESTIGATING = "Investigating"

var target: Vector3

var enemy: Enemy

func _ready() -> void:
	await owner.ready
	enemy = owner as Enemy
	assert(enemy != null)
