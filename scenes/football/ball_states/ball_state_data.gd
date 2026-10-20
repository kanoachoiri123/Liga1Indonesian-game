class_name BallStateData

# How long (in milliseconds) nobody can pick the ball up
var lock_duration := 0

static func build() -> BallStateData:
	return BallStateData.new()

func set_lock_duration(duration: int) -> BallStateData:
	lock_duration = duration
	return self
