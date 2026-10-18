class_name ActorsContainer
extends Node2D

const PLAYER_PREFAB := preload("res://scenes/Characters/player.tscn")

@export var ball: Ball
@export var home_country := "PERSIB BANDUNG"
@export var away_country := "BALI UNITED"

@onready var spawns: Node2D = %Spawns

func _ready() -> void:
	if ball == null:
		for child in get_children():
			if child is Ball:
				ball = child
	if ball == null:
		push_error("No Ball found inside ActorsContainer")
		return

	spawn_team(home_country, true)
	spawns.scale.x = -1
	spawn_team(away_country, false)

	var players := get_children().filter(func(c): return c is Player)
	if players.size() > 4:
		players[4].control_scheme = Player.ControlScheme.P1
	else:
		push_error("No players spawned. Check the country names on ActorsContainer.")

func spawn_team(country: String, is_home: bool) -> void:
	var squad: Array = DataLoader.get_squad(country)
	for i in squad.size():
		var spawn_point: Node2D = spawns.get_child(i)
		var player: Player = PLAYER_PREFAB.instantiate()
		player.initialize(spawn_point.global_position, ball, squad[i], is_home)
		add_child(player)
