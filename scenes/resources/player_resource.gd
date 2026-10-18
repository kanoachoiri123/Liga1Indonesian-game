class_name PlayerResource
extends Resource

@export var full_name: String
@export var skin_color: Player.SkinColor
@export var role: Player.Role
@export var speed: float
@export var power: float

func _init(player_name := "", player_skin := Player.SkinColor.MEDIUM, player_role := Player.Role.MIDFIELD, player_speed := 0.0, player_power := 0.0) -> void:
	full_name = player_name
	skin_color = player_skin
	role = player_role
	speed = player_speed
	power = player_power
