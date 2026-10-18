class_name PlayerStateMoving
extends StateOfPlayer

func _process(_delta: float) -> void:
	if player.control_scheme == Player.ControlScheme.CPU:
			player.velocity = Vector2.ZERO
	else:
		handle_human_movement()
	player.set_movement_animation()
	player.set_heading()


func handle_human_movement() -> void:
	var direction := KeyUtils.get_input_vector(player.control_scheme)
	player.velocity = direction * player.speed

	if player.velocity != Vector2.ZERO:
		teammate_detection_area.rotation = player.velocity.angle()

	if player.has_ball() and KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.PASS):
		transition_state(Player.State.PASSING)
	elif player.has_ball() and KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
		transition_state(Player.State.PREPPING_SHOT)
	elif player.velocity != Vector2.ZERO and KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
		transition_state(Player.State.TACKLING)
