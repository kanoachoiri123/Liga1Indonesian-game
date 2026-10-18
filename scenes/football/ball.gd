class_name Ball
extends AnimatableBody2D

enum State {CARRIED, FREEFORM, SHOT}

@export var friction_ground := 100.0
@export var bounciness := 1.0

@onready var player_detection_area : Area2D = %PlayerDetectionArea

var carrier : Player = null
var previous_carrier : Player = null
var current_state: BallState = null
var state_factory := BallStateFactory.new()
var velocity := Vector2.ZERO

func _ready() -> void:
	switch_state(State.FREEFORM)

func switch_state(new_state: State) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(new_state)
	current_state.setup(self, player_detection_area, carrier)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "BallStateMachine"
	call_deferred("add_child", current_state)

func shoot(shot_velocity: Vector2) -> void:
	velocity = shot_velocity
	previous_carrier = carrier
	carrier = null
	switch_state(State.SHOT)

func pass_to(destination: Vector2) -> void:
	var direction := position.direction_to(destination)
	var distance := position.distance_to(destination)
	var intensity := sqrt(2 * distance * friction_ground)
	velocity = intensity * direction
	previous_carrier = carrier
	carrier = null
	switch_state(State.FREEFORM)
	
func stop() -> void:
	velocity = Vector2.ZERO
