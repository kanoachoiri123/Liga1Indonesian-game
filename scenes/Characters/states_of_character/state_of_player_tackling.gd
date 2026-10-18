class_name PlayerStateTackling
extends StateOfPlayer

const GROUND_FRICTION := 250.0
const DURATION_PRE_RECOVERY := 200

var time_finish_tackle := 0
var is_stopped := false

func _enter_tree() -> void:
	animation_player.play("tackle")
	is_stopped = false

func _physics_process(delta: float) -> void:
	if not is_stopped:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, GROUND_FRICTION * delta)
		if player.velocity == Vector2.ZERO:
			is_stopped = true
			time_finish_tackle = Time.get_ticks_msec()
	elif Time.get_ticks_msec() - time_finish_tackle > DURATION_PRE_RECOVERY:
		state_transition_requested.emit(Player.State.RECOVERING)
