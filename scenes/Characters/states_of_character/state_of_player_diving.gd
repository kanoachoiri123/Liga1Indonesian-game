class_name PlayerStateDiving
extends StateOfPlayer

const DURATION_DIVE := 500

var time_start_dive := Time.get_ticks_msec()

func _enter_tree() -> void:
	# Dive along the goal line, to where the ball is on the Y axis
	var destination := Vector2(player.spawn_position.x, ball.global_position.y)
	var direction := player.global_position.direction_to(destination)
	if direction.y > 0:
		animation_player.play("dive_down")
	else:
		animation_player.play("dive_up")
	player.velocity = direction * player.speed
	time_start_dive = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_start_dive > DURATION_DIVE:
		transition_state(Player.State.RECOVERING)
