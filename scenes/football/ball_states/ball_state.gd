class_name BallState
extends Node

signal state_transition_requested(new_state: Ball.State, state_data: BallStateData)

var ball: Ball = null
var carrier: Player = null
var player_detection_area: Area2D = null
var state_data := BallStateData.new()

func setup(context_ball: Ball, context_player_detection_area: Area2D, context_carrier: Player, context_state_data: BallStateData) -> void:
	ball = context_ball
	player_detection_area = context_player_detection_area
	carrier = context_carrier
	state_data = context_state_data

# States call this instead of emitting the signal directly
func transition_state(new_state: Ball.State, data: BallStateData = BallStateData.new()) -> void:
	state_transition_requested.emit(new_state, data)

func move_and_bounce(delta: float) -> void:
	var collision := ball.move_and_collide(ball.velocity * delta)
	if collision != null:
		ball.velocity = ball.velocity.bounce(collision.get_normal()) * ball.bounciness
		transition_state(Ball.State.FREEFORM)
