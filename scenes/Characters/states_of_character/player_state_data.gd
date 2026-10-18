class_name PlayerStateData

var shot_direction := Vector2.ZERO
var shot_power := 0.0

static func build() -> PlayerStateData:
	return PlayerStateData.new()

func set_shot_direction(direction: Vector2) -> PlayerStateData:
	shot_direction = direction
	return self

func set_shot_power(power: float) -> PlayerStateData:
	shot_power = power
	return self
