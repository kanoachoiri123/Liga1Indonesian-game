class_name Player
extends CharacterBody2D

enum ControlScheme {CPU, P1, P2}
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING}
enum Role {GOALIE, DEFENSE, MIDFIELD, OFFENSE}
enum SkinColor {LIGHT, MEDIUM, DARK}

const CONTROL_SCHEME_MAP := {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png"),
}

# Number of pixel rows in the team palette image, including the top reference row
const PALETTE_ROW_COUNT := 6

# Same order as squads.json
const CLUBS := [
	"PERSIB BANDUNG",
	"DEWA UNITED",
	"BHAYANGKARA",
	"JAVA UNITED",
	"BALI UNITED",
	"AREMA",
	"PERSIJA JAKARTA",
	"MADURA UNITED",
	"BORNEO SAMARINDA",
]

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
var full_name := ""
var role := Role.MIDFIELD
var skin_color := SkinColor.MEDIUM
var is_home_team := true
var country := ""

func _ready() -> void:
	set_shader_properties()
	switch_state(State.MOVING)

func _physics_process(_delta: float) -> void:
	set_heading()
	flip_heading()
	update_control_indicator()
	move_and_slide()


func initialize(context_position: Vector2, context_ball: Ball, context_data: PlayerResource, context_is_home: bool, context_country: String) -> void:
	control_scheme = ControlScheme.CPU
	position = context_position
	ball = context_ball
	speed = context_data.speed
	power = context_data.power
	role = context_data.role
	skin_color = context_data.skin_color
	full_name = context_data.full_name
	is_home_team = context_is_home
	country = context_country
	heading = Vector2.RIGHT if context_is_home else Vector2.LEFT


func set_shader_properties() -> void:
	var material := player_sprite.material as ShaderMaterial
	if material == null:
		return
	var club_index := CLUBS.find(country)
	if club_index < 0:
		club_index = 0
	# Rows 1 to PALETTE_ROW_COUNT - 1 are team colours. Row 0 is the reference row.
	var row := 1 + (club_index % (PALETTE_ROW_COUNT - 1))
	material.set_shader_parameter("team_color", row)
	material.set_shader_parameter("skin_color", int(skin_color))


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
	return ball != null and ball.carrier == self

func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()
