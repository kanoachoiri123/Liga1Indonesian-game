class_name Player
extends CharacterBody2D

const DURATION_TACKLE := 200

enum ControlScheme {CPU, P1, P2}
enum State {MOVING, TACKLING}

@export var control_scheme : ControlScheme
@export var speed: float

@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var player_sprite : Sprite2D = %PlayerSprite

var current_state: StateOfPlayer = null
var heading := Vector2.RIGHT
var state_factory:= PlayerStateFactory.new()
var state := State.MOVING
var time_start_tackle := Time.get_ticks_msec()

func _ready() -> void:
	switch_state(State.MOVING)

func _physics_process(_delta: float) -> void:
	if control_scheme == ControlScheme.CPU:
		pass # AI logic
	else:
		if state == State.MOVING:
			if velocity.x != 0 and KeyUtils.is_action_just_pressed(control_scheme, KeyUtils.Action.SHOOT):
				state = State.TACKLING
				time_start_tackle = Time.get_ticks_msec()
				animation_player.play("tackle") # Start tackle animation once
		elif state == State.TACKLING:
			if Time.get_ticks_msec() - time_start_tackle > DURATION_TACKLE:
				state = State.MOVING

	# Only set run/idle animations if currently moving
	if state == State.MOVING:
		set_movement_animation()
	set_heading()
	flip_heading()
	move_and_slide()
	
	
func switch_state(state: State) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, animation_player)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "PlayerStateMachine:" + str(state)
	call_deferred("add_child", current_state)



func set_movement_animation() -> void:
	if velocity.length() > 0:
		animation_player.play("run")
	else:
		animation_player.play("Idle")

func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

func flip_heading() -> void:
	if heading == Vector2.RIGHT:
		player_sprite.flip_h = false
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true
	
