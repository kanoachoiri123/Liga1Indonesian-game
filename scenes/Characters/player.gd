class_name Player
extends CharacterBody2D

signal swap_requested(requester: Player)

enum ControlScheme {CPU, P1, P2}
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING, HURT, DIVING}
enum Role {GOALIE, DEFENSE, MIDFIELD, OFFENSE}
enum SkinColor {LIGHT, MEDIUM, DARK}

const CONTROL_SCHEME_MAP := {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png"),
}

# Number of pixel rows in the team palette image, including the top reference row
const PALETTE_ROW_COUNT := 9

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
var ai_behavior_factory := AIBehaviorFactory.new()
var full_name := ""
var role := Role.MIDFIELD
var skin_color := SkinColor.MEDIUM
var is_home_team := true
var country := ""
var spawn_position := Vector2.ZERO
var weight_on_duty_steering := 0.0
var own_goal: Goal = null
var target_goal: Goal = null
var ai_behavior: AIBehavior = null
var tackle_damage_emitter_area: Area2D = null
var opponent_detection_area: Area2D = null
var permanent_damage_emitter_area: Area2D = null
var goalie_hands: AnimatableBody2D = null

func _ready() -> void:
	# Players also collide with the goals' invisible walls (layer 4)
	set_collision_mask_value(4, true)
	create_detection_areas()
	create_goalie_parts()
	setup_ai_behavior()
	set_shader_properties()
	switch_state(State.MOVING)

func _physics_process(_delta: float) -> void:
	set_heading()
	flip_heading()
	update_control_indicator()
	move_and_slide()


func initialize(context_position: Vector2, context_ball: Ball, context_data: PlayerResource, context_is_home: bool, context_country: String, context_own_goal: Goal, context_target_goal: Goal) -> void:
	control_scheme = ControlScheme.CPU
	position = context_position
	spawn_position = context_position
	ball = context_ball
	speed = context_data.speed
	power = context_data.power
	role = context_data.role
	skin_color = context_data.skin_color
	full_name = context_data.full_name
	is_home_team = context_is_home
	country = context_country
	own_goal = context_own_goal
	target_goal = context_target_goal
	heading = Vector2.RIGHT if context_is_home else Vector2.LEFT


func create_detection_areas() -> void:
	# Area on the player's foot that detects a tackle hit
	tackle_damage_emitter_area = Area2D.new()
	tackle_damage_emitter_area.name = "TackleDamageEmitterArea"
	tackle_damage_emitter_area.collision_layer = 0
	tackle_damage_emitter_area.collision_mask = 2
	tackle_damage_emitter_area.monitorable = false
	tackle_damage_emitter_area.monitoring = false
	var tackle_shape := CollisionShape2D.new()
	var tackle_rectangle := RectangleShape2D.new()
	tackle_rectangle.size = Vector2(7, 7)
	tackle_shape.shape = tackle_rectangle
	tackle_shape.position = Vector2(13, -3)
	tackle_damage_emitter_area.add_child(tackle_shape)
	add_child(tackle_damage_emitter_area)
	tackle_damage_emitter_area.body_entered.connect(on_tackle_player)

	# Area in front of the player that detects opponents coming
	opponent_detection_area = Area2D.new()
	opponent_detection_area.name = "OpponentDetectionArea"
	opponent_detection_area.collision_layer = 0
	opponent_detection_area.collision_mask = 2
	opponent_detection_area.monitorable = false
	var opponent_shape := CollisionShape2D.new()
	var opponent_capsule := CapsuleShape2D.new()
	opponent_capsule.radius = 40.0
	opponent_capsule.height = 120.0
	opponent_shape.shape = opponent_capsule
	opponent_shape.rotation = PI / 2.0
	opponent_shape.position = Vector2(20, 0)
	opponent_detection_area.add_child(opponent_shape)
	add_child(opponent_detection_area)


# Only goalkeepers get these: hands that bounce the ball away, and a zone that hurts opponents
func create_goalie_parts() -> void:
	if role != Role.GOALIE:
		return

	permanent_damage_emitter_area = Area2D.new()
	permanent_damage_emitter_area.name = "PermanentDamageEmitterArea"
	permanent_damage_emitter_area.collision_layer = 0
	permanent_damage_emitter_area.collision_mask = 2
	permanent_damage_emitter_area.monitorable = false
	permanent_damage_emitter_area.monitoring = true
	var damage_shape := CollisionShape2D.new()
	var damage_rectangle := RectangleShape2D.new()
	damage_rectangle.size = Vector2(7, 7)
	damage_shape.shape = damage_rectangle
	damage_shape.position = Vector2(0, -6)
	permanent_damage_emitter_area.add_child(damage_shape)
	add_child(permanent_damage_emitter_area)
	permanent_damage_emitter_area.body_entered.connect(on_tackle_player)

	goalie_hands = AnimatableBody2D.new()
	goalie_hands.name = "GoalieHands"
	goalie_hands.sync_to_physics = false
	goalie_hands.collision_layer = 32
	goalie_hands.collision_mask = 0
	var hands_shape := CollisionShape2D.new()
	var hands_capsule := CapsuleShape2D.new()
	hands_capsule.radius = 3.0
	hands_capsule.height = 18.0
	hands_shape.shape = hands_capsule
	hands_shape.position = Vector2(0, -4)
	goalie_hands.add_child(hands_shape)
	add_child(goalie_hands)


func setup_ai_behavior() -> void:
	ai_behavior = ai_behavior_factory.get_ai_behavior(role)
	ai_behavior.setup(self, ball, opponent_detection_area, teammate_detection_area)
	ai_behavior.name = "AIBehavior"
	add_child(ai_behavior)


func on_tackle_player(body: Node2D) -> void:
	if body is Player and body != self and body.is_home_team != is_home_team and body.has_ball():
		body.get_hurt(global_position.direction_to(body.global_position))


func get_hurt(hurt_origin: Vector2) -> void:
	switch_state(State.HURT, PlayerStateData.build().set_hurt_direction(hurt_origin))


# NEW: a human teammate asks me (the ball carrier) to pass to them
func get_pass_request(requester: Player) -> void:
	if ball.carrier != self:
		return
	if current_state == null or not current_state.can_pass():
		return
	switch_state(State.PASSING, PlayerStateData.build().set_pass_target(requester))


func is_facing_target_goal() -> bool:
	var direction_to_target_goal := global_position.direction_to(target_goal.global_position)
	return heading.dot(direction_to_target_goal) > 0


func can_carry_ball() -> bool:
	return current_state != null and current_state.can_carry_ball()


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
	var facing_left := heading == Vector2.LEFT
	player_sprite.flip_h = facing_left
	var side := -1.0 if facing_left else 1.0
	tackle_damage_emitter_area.scale.x = side
	opponent_detection_area.scale.x = side

func has_ball() -> bool:
	return ball != null and ball.carrier == self

func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()
