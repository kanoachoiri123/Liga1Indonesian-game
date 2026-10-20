class_name BallStateFreeform
extends BallState

var time_since_freeform := Time.get_ticks_msec()

func _enter_tree() -> void:
	time_since_freeform = Time.get_ticks_msec()
	player_detection_area.body_entered.connect(on_player_enter.bind())

func _process(delta: float) -> void:
	update_pickup_lock()
	ball.velocity = ball.velocity.move_toward(Vector2.ZERO, ball.friction_ground * delta)
	move_and_bounce(delta)

# The pickup area only listens once the lock time has passed
func update_pickup_lock() -> void:
	var lock_finished := Time.get_ticks_msec() - time_since_freeform >= state_data.lock_duration
	if player_detection_area.monitoring != lock_finished:
		player_detection_area.set_deferred("monitoring", lock_finished)

func on_player_enter(body: Player) -> void:
	if not body.can_carry_ball():
		return
	var giver := ball.previous_carrier
	if body.control_scheme == Player.ControlScheme.CPU and giver != null and giver != body and giver.control_scheme != Player.ControlScheme.CPU and giver.is_home_team == body.is_home_team:
		body.control_scheme = giver.control_scheme
		giver.control_scheme = Player.ControlScheme.CPU
	ball.carrier = body
	transition_state(Ball.State.CARRIED)
