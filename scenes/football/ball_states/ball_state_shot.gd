class_name BallStateShot
extends BallState

const DURATION_SHOT := 1000

var time_start_shot := Time.get_ticks_msec()

func _enter_tree() -> void:
	time_start_shot = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - time_start_shot > DURATION_SHOT:
		state_transition_requested.emit(Ball.State.FREEFORM)
	else:
		ball.move_and_collide(ball.velocity * delta)
