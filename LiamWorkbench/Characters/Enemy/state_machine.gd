extends StateMachine

func _init() -> void:
	if get_parent().debug:
		self.initial_state = $Idle
	else:
		self.initial_state = $Patrolling
