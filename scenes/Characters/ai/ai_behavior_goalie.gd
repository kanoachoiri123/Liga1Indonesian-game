class_name AIBehaviorGoalie
extends AIBehavior

func perform_ai_movement() -> void:
	var total_steering_force := get_goalie_steering_force()
	total_steering_force = total_steering_force.limit_length(1.0)
	player.velocity = total_steering_force * player.speed


func perform_ai_decisions() -> void:
	# If the ball is heading into my goal, dive
	if ball.is_headed_for_scoring_area(player.own_goal.get_scoring_area()):
		player.switch_state(Player.State.DIVING)


# Stay on my line and follow the ball up and down, between the top and bottom aim points
func get_goalie_steering_force() -> Vector2:
	var top_limit := player.own_goal.get_top_target_position()
	var bottom_limit := player.own_goal.get_bottom_target_position()
	var target_y := clampf(ball.global_position.y, top_limit.y, bottom_limit.y)
	var destination := Vector2(player.spawn_position.x, target_y)
	var direction := player.global_position.direction_to(destination)
	var distance_to_destination := player.global_position.distance_to(destination)
	# Run flat out when far, slow down in the last 10 pixels
	var weight := clampf(distance_to_destination / 10.0, 0.0, 1.0)
	return weight * direction
