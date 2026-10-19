class_name AIBehavior
extends Node

const DURATION_AI_TICK_FREQUENCY := 200

var player: Player = null
var ball: Ball = null
var opponent_detection_area: Area2D = null
var time_since_last_ai_tick := Time.get_ticks_msec()

func setup(context_player: Player, context_ball: Ball, context_opponent_detection_area: Area2D) -> void:
	player = context_player
	ball = context_ball
	opponent_detection_area = context_opponent_detection_area
	# Random start so the CPU players don't all think on the same frame
	time_since_last_ai_tick = Time.get_ticks_msec() + randi_range(0, DURATION_AI_TICK_FREQUENCY)


func process_ai() -> void:
	if Time.get_ticks_msec() - time_since_last_ai_tick > DURATION_AI_TICK_FREQUENCY:
		time_since_last_ai_tick = Time.get_ticks_msec()
		perform_ai_movement()
		perform_ai_decisions()


# Each role overrides these two
func perform_ai_movement() -> void:
	pass

func perform_ai_decisions() -> void:
	pass


# ---------- Shared helpers ----------

func get_bicircular_weight(from_position: Vector2, center_target: Vector2, inner_circle_radius: float, inner_circle_weight: float, outer_circle_radius: float, outer_circle_weight: float) -> float:
	var distance_to_center := from_position.distance_to(center_target)
	if distance_to_center > outer_circle_radius:
		return outer_circle_weight
	elif distance_to_center < inner_circle_radius:
		return inner_circle_weight
	var distance_to_inner_radius := distance_to_center - inner_circle_radius
	var close_range_distance := outer_circle_radius - inner_circle_radius
	return lerpf(inner_circle_weight, outer_circle_weight, distance_to_inner_radius / close_range_distance)


func is_ball_carried_by_teammate() -> bool:
	return ball.carrier != null and ball.carrier != player and ball.carrier.is_home_team == player.is_home_team


func is_ball_possessed_by_opponent() -> bool:
	return ball.carrier != null and ball.carrier.is_home_team != player.is_home_team


func has_opponents_nearby() -> bool:
	for body in opponent_detection_area.get_overlapping_bodies():
		if body is Player and body.is_home_team != player.is_home_team:
			return true
	return false


func face_towards_goal() -> void:
	if not player.is_facing_target_goal():
		player.heading *= -1
