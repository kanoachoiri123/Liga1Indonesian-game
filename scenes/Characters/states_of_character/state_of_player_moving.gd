class_name PlayerStateMoving
extends StateOfPlayer

func _process(_delta: float) -> void:
	if player.control_scheme == Player.ControlScheme.CPU:
		player.ai_behavior.process_ai()
	else:
		handle_human_movement()
	if player.velocity != Vector2.ZERO:
		teammate_detection_area.rotation = player.velocity.angle()
	player.set_movement_animation()
	player.set_heading()


func handle_human_movement() -> void:
	var direction := KeyUtils.get_input_vector(player.control_scheme)
	player.velocity = direction * player.speed

	if KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.PASS):
		if player.has_ball():
			transition_state(Player.State.PASSING)
		elif can_teammate_pass_ball():
			# Ask the CPU teammate holding the ball to pass to me
			ball.carrier.get_pass_request(player)
		else:
			# Take over the CPU teammate closest to the ball
			player.swap_requested.emit(player)
	elif KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
		if player.has_ball():
			transition_state(Player.State.PREPPING_SHOT)
		elif player.velocity != Vector2.ZERO:
			transition_state(Player.State.TACKLING)


# A teammate holds the ball and is controlled by the CPU
func can_teammate_pass_ball() -> bool:
	return ball.carrier != null and ball.carrier.is_home_team == player.is_home_team and ball.carrier.control_scheme == Player.ControlScheme.CPU


func can_carry_ball() -> bool:
	return player.role != Player.Role.GOALIE


func can_pass() -> bool:
	return true
