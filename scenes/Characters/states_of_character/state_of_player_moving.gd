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

	if player.has_ball():
		if KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.PASS):
			transition_state(Player.State.PASSING)
		elif KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
			transition_state(Player.State.PREPPING_SHOT)
	elif KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT) and player.velocity != Vector2.ZERO:
		transition_state(Player.State.TACKLING)


func can_carry_ball() -> bool:
	return player.role != Player.Role.GOALIE
