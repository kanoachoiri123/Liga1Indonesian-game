extends Node

const SCENE_MENU := "res://scenes/screens/main_menu.tscn"
const SCENE_TEAM_SELECT := "res://scenes/screens/team_select.tscn"
const SCENE_BRACKET := "res://scenes/screens/bracket.tscn"
const SCENE_RESULT := "res://scenes/screens/result.tscn"
const SCENE_MATCH := "res://scenes/world.tscn"
const TEAMS_IN_BRACKET := 8

enum Status {NONE, IN_PROGRESS, ELIMINATED, CHAMPION}

var status := Status.NONE
var in_tournament := false
var player_team := ""
var rounds: Array = []        # rounds[i] = array of fixture dictionaries
var round_index := 0
var match_home := ""          # read by ActorsContainer when a match loads
var match_away := ""
var last_match_text := ""
var last_round_name := ""


func start_tournament(team: String) -> void:
	player_team = team
	var others: Array = DataLoader.squads.keys()
	others.erase(team)
	others.shuffle()
	var teams: Array = [team]
	teams.append_array(others.slice(0, TEAMS_IN_BRACKET - 1))
	teams.shuffle()
	rounds = [_make_round(teams)]
	round_index = 0
	status = Status.IN_PROGRESS
	in_tournament = true
	last_match_text = ""
	last_round_name = ""


func reset() -> void:
	status = Status.NONE
	in_tournament = false
	player_team = ""
	rounds.clear()
	round_index = 0


func _make_round(teams: Array) -> Array:
	var result: Array = []
	for i in range(0, teams.size(), 2):
		result.append({
			"home": teams[i], "away": teams[i + 1],
			"home_goals": -1, "away_goals": -1, "winner": ""
		})
	return result


func _player_fixture() -> Dictionary:
	for fixture in rounds[round_index]:
		if fixture["home"] == player_team or fixture["away"] == player_team:
			return fixture
	return {}


func next_opponent() -> String:
	var fixture := _player_fixture()
	if fixture.is_empty():
		return ""
	return fixture["away"] if fixture["home"] == player_team else fixture["home"]


func start_player_match() -> void:
	match_home = player_team
	match_away = next_opponent()
	get_tree().change_scene_to_file(SCENE_MATCH)


# Called by the match when full time (or the golden goal) is reached
func report_player_match(player_goals: int, opponent_goals: int, player_won: bool) -> void:
	var fixture := _player_fixture()
	if fixture.is_empty():
		return
	var player_is_home: bool = fixture["home"] == player_team
	fixture["home_goals"] = player_goals if player_is_home else opponent_goals
	fixture["away_goals"] = opponent_goals if player_is_home else player_goals
	var opponent: String = fixture["away"] if player_is_home else fixture["home"]
	fixture["winner"] = player_team if player_won else opponent

	last_round_name = round_name_for_index(round_index)
	last_match_text = "%s %d - %d %s" % [player_team, player_goals, opponent_goals, opponent]
	if player_goals == opponent_goals:
		last_match_text += " (penalties)"

	_simulate_remaining(round_index)

	if not player_won:
		status = Status.ELIMINATED
	elif rounds[round_index].size() == 1:
		status = Status.CHAMPION        # only the final has a single fixture
	else:
		_build_next_round()


func next_scene_after_match() -> String:
	return SCENE_BRACKET if status == Status.IN_PROGRESS else SCENE_RESULT


func _simulate_remaining(index: int) -> void:
	for fixture in rounds[index]:
		if fixture["winner"] != "":
			continue
		var h := randi_range(0, 4)
		var a := randi_range(0, 4)
		while h == a:
			h = randi_range(0, 4)
			a = randi_range(0, 4)
		fixture["home_goals"] = h
		fixture["away_goals"] = a
		fixture["winner"] = fixture["home"] if h > a else fixture["away"]


func _build_next_round() -> void:
	var winners: Array = []
	for fixture in rounds[round_index]:
		winners.append(fixture["winner"])
	round_index += 1
	rounds.append(_make_round(winners))


# ---------- helpers for the bracket screen ----------

func total_rounds() -> int:
	var count := 0
	var n: int = rounds[0].size()
	while n >= 1:
		count += 1
		n = n >> 1
	return count


func matches_in_round(index: int) -> int:
	return rounds[0].size() >> index


func round_name_for_index(index: int) -> String:
	match matches_in_round(index):
		1: return "FINAL"
		2: return "SEMI-FINALS"
		4: return "QUARTER-FINALS"
	return "ROUND %d" % (index + 1)
