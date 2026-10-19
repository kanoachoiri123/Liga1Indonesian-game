class_name ActorsContainer
extends Node2D

const PLAYER_PREFAB := preload("res://scenes/Characters/player.tscn")
const DURATION_WEIGHT_CACHE := 200

@export var ball: Ball
@export var home_country := "PERSIB BANDUNG"
@export var away_country := "BALI UNITED"

@onready var spawns: Node2D = %Spawns

var squad_home: Array = []
var squad_away: Array = []
var time_since_last_cache_refresh := Time.get_ticks_msec()

func _ready() -> void:
	if ball == null:
		for child in get_children():
			if child is Ball:
				ball = child
	if ball == null:
		push_error("No Ball found inside ActorsContainer")
		return

	# Find the two goals. The left one belongs to the home team.
	var goals := find_children("*", "Node2D", true, false).filter(func(n): return n is Goal)
	if goals.size() < 2:
		push_error("Could not find two Goal nodes")
		return
	goals.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)
	var goal_home: Goal = goals[0]
	var goal_away: Goal = goals[1]

	squad_home = spawn_team(home_country, true, goal_home, goal_away)
	spawns.scale.x = -1
	squad_away = spawn_team(away_country, false, goal_away, goal_home)

	if squad_home.size() > 4:
		squad_home[4].control_scheme = Player.ControlScheme.P1
	else:
		push_error("No players spawned. Check the country names on ActorsContainer.")


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_last_cache_refresh > DURATION_WEIGHT_CACHE:
		time_since_last_cache_refresh = Time.get_ticks_msec()
		set_on_duty_weights()


func spawn_team(country: String, is_home: bool, own_goal: Goal, target_goal: Goal) -> Array:
	var squad: Array = DataLoader.get_squad(country)
	var spawned: Array = []
	for i in squad.size():
		var spawn_point: Node2D = spawns.get_child(i)
		var player: Player = PLAYER_PREFAB.instantiate()
		player.initialize(spawn_point.global_position, ball, squad[i], is_home, country, own_goal, target_goal)
		spawned.append(player)
		add_child(player)
	return spawned


# The CPU players whose spawn point is closest to the ball get the biggest chase weight
func set_on_duty_weights() -> void:
	for squad in [squad_home, squad_away]:
		var cpu_players: Array = squad.filter(func(p: Player): return p.control_scheme == Player.ControlScheme.CPU and p.role != Player.Role.GOALIE)
		cpu_players.sort_custom(func(p1: Player, p2: Player): return p1.spawn_position.distance_squared_to(ball.global_position) < p2.spawn_position.distance_squared_to(ball.global_position))
		for i in cpu_players.size():
			cpu_players[i].weight_on_duty_steering = 1.0 - ease(float(i) / 10.0, 0.1)
