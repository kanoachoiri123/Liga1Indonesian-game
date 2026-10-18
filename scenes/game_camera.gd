class_name GameCamera
extends Camera2D

const DISTANCE_TARGET := 100.0
const SMOOTHING_BALL_CARRIED := 3.0
const SMOOTHING_BALL_DEFAULT := 8.0

@export var ball: Ball

func _process(_delta: float) -> void:
	if ball.carrier != null:
		global_position = ball.carrier.global_position + ball.carrier.heading * DISTANCE_TARGET
		position_smoothing_speed = SMOOTHING_BALL_CARRIED
	else:
		global_position = ball.global_position
		position_smoothing_speed = SMOOTHING_BALL_DEFAULT
