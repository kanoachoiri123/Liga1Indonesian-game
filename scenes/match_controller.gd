class_name MatchController
extends Node

const MATCH_SECONDS := 120.0          # change this to make matches shorter or longer
const SUDDEN_DEATH_SECONDS := 60.0
const KICKOFF_DELAY := 2.0
const GOAL_BANNER_SECONDS := 2.5
const FULL_TIME_SECONDS := 3.0
const BALL_START := Vector2(425, 180)

var actors: Node
var ball: Ball
var goal_home: Goal
var goal_away: Goal
var home_name := ""
var away_name := ""

var home_goals := 0
var away_goals := 0
var time_left := MATCH_SECONDS
var sudden_left := 0.0
var sudden_death := false
var playing := false

var home_label: Label
var away_label: Label
var score_label: Label
var time_label: Label
var banner: PanelContainer
var banner_title: Label
var banner_sub: Label


func setup(context_actors: Node, context_ball: Ball, context_goal_home: Goal, context_goal_away: Goal, context_home: String, context_away: String) -> void:
	actors = context_actors
	ball = context_ball
	goal_home = context_goal_home
	goal_away = context_goal_away
	home_name = context_home
	away_name = context_away


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS    # keeps running while the game is paused
	_build_hud()
	goal_home.goal_scored.connect(_on_goal_scored)
	goal_away.goal_scored.connect(_on_goal_scored)
	MusicPlayer.set_in_match(true)
	_update_hud()
	_begin_play()


func _process(delta: float) -> void:
	if not playing:
		return
	if sudden_death:
		sudden_left -= delta
		if sudden_left <= 0.0:
			_finish_match(randi() % 2 == 0)       # nobody scored: penalties coin flip
	else:
		time_left -= delta
		if time_left <= 0.0:
			time_left = 0.0
			if home_goals == away_goals:
				_start_sudden_death()
			else:
				_finish_match(true)
	_update_hud()


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true).timeout


func _begin_play() -> void:
	get_tree().paused = true
	_show_banner("KICK OFF", "%s  vs  %s" % [home_name, away_name])
	await _wait(KICKOFF_DELAY)
	_hide_banner()
	get_tree().paused = false
	playing = true


func _start_sudden_death() -> void:
	sudden_death = true
	sudden_left = SUDDEN_DEATH_SECONDS
	_show_banner("GOLDEN GOAL", "Next goal wins!")
	await _wait(1.5)
	if playing:
		_hide_banner()


func _on_goal_scored(conceding_home: bool) -> void:
	if not playing:
		return                                     # already handling this goal
	playing = false
	get_tree().paused = true

	var scoring_home := not conceding_home
	if scoring_home:
		home_goals += 1
	else:
		away_goals += 1

	# Scorer = whoever holds the ball, otherwise the last shooter/passer
	var scorer: Player = ball.carrier if ball.carrier != null else ball.previous_carrier
	var scorer_text := "Unknown"
	if scorer != null:
		scorer_text = scorer.full_name
		if scorer.is_home_team != scoring_home:
			scorer_text += " (OG)"
	var team_text := home_name if scoring_home else away_name

	_update_hud()
	_show_banner("GOAL!", "%s\n%s" % [scorer_text, team_text])
	await _wait(GOAL_BANNER_SECONDS)

	if sudden_death:
		_finish_match(true)
		return

	actors.reset_for_kickoff()
	_show_banner("KICK OFF", "%d - %d" % [home_goals, away_goals])
	await _wait(KICKOFF_DELAY)
	_hide_banner()
	get_tree().paused = false
	playing = true


func _finish_match(penalties_home_wins: bool) -> void:
	playing = false
	get_tree().paused = true
	var home_won := home_goals > away_goals
	var sub := "%s  %d - %d  %s" % [home_name, home_goals, away_goals, away_name]
	if home_goals == away_goals:
		home_won = penalties_home_wins
		sub += "\nWon on penalties: " + (home_name if home_won else away_name)
	_show_banner("FULL TIME", sub)
	_update_hud()
	await _wait(FULL_TIME_SECONDS)

	get_tree().paused = false
	MusicPlayer.set_in_match(false)
	if Tournament.in_tournament:
		# Your team is always the home team in a tournament match
		Tournament.report_player_match(home_goals, away_goals, home_won)
		get_tree().change_scene_to_file(Tournament.next_scene_after_match())
	else:
		get_tree().change_scene_to_file(Tournament.SCENE_MENU)


# ---------- HUD (built in code) ----------

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var bar := PanelContainer.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	bar.add_theme_stylebox_override("panel", UIStyle.panel_style())
	root.add_child(bar)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	bar.add_child(row)
	home_label = UIStyle.label(home_name, 14)
	score_label = UIStyle.label("0 - 0", 18, UIStyle.COLOR_ACCENT)
	away_label = UIStyle.label(away_name, 14)
	time_label = UIStyle.label("02:00", 14)
	for l in [home_label, score_label, away_label, time_label]:
		row.add_child(l)

	banner = PanelContainer.new()
	banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	banner.grow_vertical = Control.GROW_DIRECTION_BOTH
	banner.add_theme_stylebox_override("panel", UIStyle.panel_style(Color(0, 0, 0, 0.75)))
	banner.visible = false
	root.add_child(banner)
	var box := VBoxContainer.new()
	banner.add_child(box)
	banner_title = UIStyle.label("", 36, UIStyle.COLOR_ACCENT)
	banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_sub = UIStyle.label("", 16)
	banner_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(banner_title)
	box.add_child(banner_sub)


func _update_hud() -> void:
	score_label.text = "%d - %d" % [home_goals, away_goals]
	if sudden_death:
		time_label.text = "GOLDEN GOAL"
	else:
		var total := int(ceil(time_left))
		time_label.text = "%02d:%02d" % [total / 60, total % 60]


func _show_banner(title: String, sub: String = "") -> void:
	banner_title.text = title
	banner_sub.text = sub
	banner.visible = true


func _hide_banner() -> void:
	banner.visible = false
