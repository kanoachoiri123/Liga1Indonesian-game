class_name PlayerStateHurt
extends StateOfPlayer

const DURATION_HURT := 1000
const AIR_FRICTION := 35.0
const BALL_TUMBLE_SPEED := 100.0

var time_start_hurt := Time.get_ticks_msec()

func _enter_tree() -> void:
	animation_player.play("hurt")
	time_start_hurt = Time.get_ticks_msec()
	if ball.carrier == player:
		ball.tumble(state_data.hurt_direction * BALL_TUMBLE_SPEED)

func _process(delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, AIR_FRICTION * delta)
	if Time.get_ticks_msec() - time_start_hurt > DURATION_HURT:
		transition_state(Player.State.RECOVERING)
