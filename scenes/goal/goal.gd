class_name Goal
extends Node2D

# Aim points in the goal's local space (top, centre, bottom)
const TARGET_OFFSETS := [Vector2(22, -56), Vector2(22, -35), Vector2(22, -10)]

@onready var back_net_area: Area2D = %BackNetArea

var scoring_area: Area2D = null

func _ready() -> void:
	back_net_area.body_entered.connect(on_ball_enter_back_net.bind())
	create_invisible_wall()
	create_scoring_area()


# Blocks players (collision layer 4) but not the ball
func create_invisible_wall() -> void:
	var wall := StaticBody2D.new()
	wall.name = "InvisibleWalls"
	wall.collision_layer = 8
	wall.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(6, 60)
	shape.shape = rectangle
	shape.position = Vector2(20, -35)
	wall.add_child(shape)
	add_child(wall)


# On collision layer 5. The ball's raycast looks for this to know if a shot is going in
func create_scoring_area() -> void:
	scoring_area = Area2D.new()
	scoring_area.name = "ScoringArea"
	scoring_area.collision_layer = 16
	scoring_area.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(6, 60)
	shape.shape = rectangle
	shape.position = Vector2(0, -35)
	scoring_area.add_child(shape)
	add_child(scoring_area)


func on_ball_enter_back_net(ball: Ball) -> void:
	ball.stop()

func get_scoring_area() -> Area2D:
	return scoring_area

func get_random_target_position() -> Vector2:
	return to_global(TARGET_OFFSETS.pick_random())

func get_center_target_position() -> Vector2:
	return to_global(TARGET_OFFSETS[1])

func get_top_target_position() -> Vector2:
	return to_global(TARGET_OFFSETS[0])

func get_bottom_target_position() -> Vector2:
	return to_global(TARGET_OFFSETS[2])
