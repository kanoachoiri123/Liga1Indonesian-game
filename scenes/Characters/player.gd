class_name Player
extends CharacterBody2D

enum ControlScheme {CPU, P1, P2}
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING}

const CONTROL_SCHEME_MAP := {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png"),
}

@export var control_scheme : ControlScheme
@export var speed: float
@export var power: float = 70
@export var ball : Ball

@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var player_sprite : Sprite2D = %PlayerSprite
@onready var teammate_detection_area : Area2D = %TeammateDetectionArea
@onready var control_sprite : Sprite2D = %ControlSprite

var current_state: StateOfPlayer = null
var heading := Vector2.RIGHT
var state_factory := PlayerStateFactory.new()

func _ready() -> void:
	switch_state(State.MOVING)

func _physics_process(_delta: float) -> void:
	set_heading()
	flip_heading()
	update_control_indicator()
	move_and_slide()


func switch_state(new_state: State, state_data: PlayerStateData = PlayerStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(new_state)
	current_state.setup(self, state_data, animation_player, ball, teammate_detection_area)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "PlayerStateMachine:" + str(new_state)
	call_deferred("add_child", current_state)


func update_control_indicator() -> void:
	control_sprite.texture = CONTROL_SCHEME_MAP[control_scheme]
	control_sprite.visible = control_scheme != ControlScheme.CPU or has_ball()

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

func has_ball() -> bool:
	return ball.carrier == self

func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()
