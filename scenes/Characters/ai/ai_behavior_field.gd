class_name AIBehaviorField
extends AIBehavior

const SHOT_DISTANCE := 150.0
const SHOT_PROBABILITY := 0.3
const TACKLE_DISTANCE := 15.0
const TACKLE_PROBABILITY := 0.3
const PASS_PROBABILITY := 0.05
const SPREAD_FACTOR := 0.8

func perform_ai_movement() -> void:
	var total_steering_force := Vector2.ZERO
	if player.has_ball():
		# The ball carrier only cares about scoring
		total_steering_force += get_carrier_steering_force()
	elif is_ball_carried_by_teammate():
		# Support the teammate who has the ball
		total_steering_force += get_assist_formation_steering_force()
	else:
		# Ball is free or with the opponents
		total_steering_force += get_on_duty_steering_force()
		# If I'm not the main chaser, do something useful instead of standing around
		if total_steering_force.length() < 0.99:
			if is_ball_possessed_by_opponent():
				total_steering_force += get_spawn_steering_force()
			else:
				total_steering_force += get_ball_proximity_steering_force()
	total_steering_force = total_steering_force.limit_length(1.0)
	player.velocity = total_steering_force * player.speed


func perform_ai_decisions() -> void:
	if player.has_ball():
		var target := player.target_goal.get_center_target_position()
		if player.global_position.distance_to(target) < SHOT_DISTANCE and randf() < SHOT_PROBABILITY:
			face_towards_goal()
			var shot_direction := player.global_position.direction_to(player.target_goal.get_random_target_position())
			var data := PlayerStateData.build().set_shot_power(player.power).set_shot_direction(shot_direction)
			player.switch_state(Player.State.SHOOTING, data)
		# Cheap checks first, the area checks last
		elif randf() < PASS_PROBABILITY and has_opponents_nearby() and has_teammate_in_view():
			player.switch_state(Player.State.PASSING)
	elif is_ball_possessed_by_opponent():
		if player.global_position.distance_to(ball.global_position) < TACKLE_DISTANCE and randf() < TACKLE_PROBABILITY:
			player.velocity = player.global_position.direction_to(ball.global_position) * player.speed
			player.switch_state(Player.State.TACKLING)


func get_on_duty_steering_force() -> Vector2:
	return player.weight_on_duty_steering * player.global_position.direction_to(ball.global_position)


func get_carrier_steering_force() -> Vector2:
	var target := player.target_goal.get_center_target_position()
	var direction := player.global_position.direction_to(target)
	var weight := get_bicircular_weight(player.global_position, target, 100.0, 0.0, 150.0, 1.0)
	return weight * direction


func get_assist_formation_steering_force() -> Vector2:
	var spawn_difference := ball.carrier.spawn_position - player.spawn_position
	var assist_destination := ball.carrier.global_position - spawn_difference * SPREAD_FACTOR
	var direction := player.global_position.direction_to(assist_destination)
	var weight := get_bicircular_weight(player.global_position, assist_destination, 30.0, 0.2, 60.0, 1.0)
	return weight * direction


# NEW: a ball that comes within 120 px pulls the player in, at full strength inside 50 px
func get_ball_proximity_steering_force() -> Vector2:
	var direction := player.global_position.direction_to(ball.global_position)
	var weight := get_bicircular_weight(player.global_position, ball.global_position, 50.0, 1.0, 120.0, 0.0)
	return weight * direction


# NEW: pull back to the spawn point. No pull within 30 px, full pull beyond 100 px
func get_spawn_steering_force() -> Vector2:
	var direction := player.global_position.direction_to(player.spawn_position)
	var weight := get_bicircular_weight(player.global_position, player.spawn_position, 30.0, 0.0, 100.0, 1.0)
	return weight * direction
