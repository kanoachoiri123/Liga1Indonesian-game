class_name BallStateFreeform
extends BallState

func _enter_tree() -> void:
	player_detection_area.body_entered.connect(on_player_enter.bind())

func _process(delta: float) -> void:
	ball.velocity = ball.velocity.move_toward(Vector2.ZERO, ball.friction_ground * delta)
	move_and_bounce(delta)

func on_player_enter(body: Player) -> void:
	if not body.is_home_team:
		return
	var giver := ball.previous_carrier
	if body.control_scheme == Player.ControlScheme.CPU and giver != null and giver != body and giver.control_scheme != Player.ControlScheme.CPU:
		body.control_scheme = giver.control_scheme
		giver.control_scheme = Player.ControlScheme.CPU
	ball.carrier = body
	state_transition_requested.emit(Ball.State.CARRIED)
