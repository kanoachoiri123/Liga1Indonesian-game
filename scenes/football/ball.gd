class_name Ball
extends AnimatableBody2D

enum State {CARRIED, FREEFORM, SHOT}

const DURATION_TUMBLE_LOCK := 200
const DURATION_PASS_LOCK := 500

@export var friction_ground := 100.0
@export var bounciness := 0.8

@onready var player_detection_area : Area2D = %PlayerDetectionArea

var carrier : Player = null
var previous_carrier : Player = null
var current_state: BallState = null
var state_factory := BallStateFactory.new()
var velocity := Vector2.ZERO
var scoring_raycast: RayCast2D = null

func _ready() -> void:
	# Also bounce off the goalkeeper's hands (layer 6)
	set_collision_mask_value(6, true)
	create_scoring_raycast()
	switch_state(State.FREEFORM)

func _process(_delta: float) -> void:
	scoring_raycast.rotation = velocity.angle()

func create_scoring_raycast() -> void:
	scoring_raycast = RayCast2D.new()
	scoring_raycast.name = "ScoringRaycast"
	scoring_raycast.target_position = Vector2(80, 0)
	scoring_raycast.position = Vector2(0, -5)
	scoring_raycast.collision_mask = 16
	scoring_raycast.collide_with_areas = true
	scoring_raycast.collide_with_bodies = false
	add_child(scoring_raycast)

func switch_state(new_state: State, state_data: BallStateData = BallStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(new_state)
	current_state.setup(self, player_detection_area, carrier, state_data)
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
	switch_state(State.FREEFORM, BallStateData.build().set_lock_duration(DURATION_PASS_LOCK))

func tumble(tumble_velocity: Vector2) -> void:
	velocity = tumble_velocity
	previous_carrier = carrier
	carrier = null
	switch_state(State.FREEFORM, BallStateData.build().set_lock_duration(DURATION_TUMBLE_LOCK))

func stop() -> void:
	velocity = Vector2.ZERO

# True if the ball is moving and its ray hits the given scoring area
func is_headed_for_scoring_area(scoring_area: Area2D) -> bool:
	if scoring_area == null or velocity.length() < 10.0:
		return false
	if not scoring_raycast.is_colliding():
		return false
	return scoring_raycast.get_collider() == scoring_area
	
	
func reset_for_kickoff(kickoff_position: Vector2) -> void:
	position = kickoff_position
	velocity = Vector2.ZERO
	carrier = null
	previous_carrier = null
	switch_state(State.FREEFORM)
