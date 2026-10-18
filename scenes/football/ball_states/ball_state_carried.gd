class_name BallStateCarried
extends BallState

const DRIBBLE_FREQUENCY := 10.0
const DRIBBLE_INTENSITY := 3.0
const OFFSET_FROM_PLAYER := Vector2(10, 4)

var dribble_time := 0.0

func _enter_tree() -> void:
	assert(carrier != null)

func _process(delta: float) -> void:
	var vx := 0.0
	if carrier.velocity.x != 0:
		dribble_time += delta
		vx = cos(dribble_time * DRIBBLE_FREQUENCY) * DRIBBLE_INTENSITY
	ball.position = carrier.position + Vector2(vx + carrier.heading.x * OFFSET_FROM_PLAYER.x, OFFSET_FROM_PLAYER.y)
