class_name BallState
extends Node

signal state_transition_requested(new_state: Ball.State)

var ball: Ball = null
var carrier: Player = null
var player_detection_area: Area2D = null

func setup(context_ball: Ball, context_player_detection_area: Area2D, context_carrier: Player) -> void:
	ball = context_ball
	player_detection_area = context_player_detection_area
	carrier = context_carrier

func move_and_bounce(delta: float) -> void:
	var collision := ball.move_and_collide(ball.velocity * delta)
	if collision != null:
		ball.velocity = ball.velocity.bounce(collision.get_normal()) * ball.bounciness
		state_transition_requested.emit(Ball.State.FREEFORM)
