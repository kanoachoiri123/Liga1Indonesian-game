class_name PlayerStateFactory

var states: Dictionary

func _init() -> void:
	states = {
		Player.State.DIVING: PlayerStateDiving,
		Player.State.HURT: PlayerStateHurt,
		Player.State.MOVING: PlayerStateMoving,
		Player.State.PASSING: PlayerStatePassing,
		Player.State.PREPPING_SHOT: PlayerStatePreppingShot,
		Player.State.RECOVERING: PlayerStateRecovering,
		Player.State.SHOOTING: PlayerStateShooting,
		Player.State.TACKLING: PlayerStateTackling,
	}


func get_fresh_state(state: Player.State) -> StateOfPlayer:
	assert(states.has(state), "state don't exist")
	return states.get(state).new()
