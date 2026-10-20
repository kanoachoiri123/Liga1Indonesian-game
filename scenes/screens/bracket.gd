extends Control

func _ready() -> void:
	if Tournament.rounds.is_empty():
		get_tree().change_scene_to_file.call_deferred(Tournament.SCENE_MENU)
		return
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	MusicPlayer.play_track(MusicPlayer.Track.TOURNAMENT)
	UIStyle.add_background(self, UIStyle.find_asset(UIStyle.TEAMSEL_DIR, "team-selection-bac"))

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", UIStyle.px(8))
	center.add_child(root)

	var title := UIStyle.label("KNOCKOUT TOURNAMENT", 22, UIStyle.COLOR_ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	var columns := HBoxContainer.new()
	columns.alignment = BoxContainer.ALIGNMENT_CENTER
	columns.add_theme_constant_override("separation", UIStyle.px(10))
	root.add_child(columns)
	for i in Tournament.total_rounds():
		columns.add_child(_build_round(i))

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", UIStyle.px(10))
	root.add_child(buttons)
	var play := UIStyle.button("PLAY vs " + Tournament.next_opponent(), Tournament.start_player_match, 10)
	play.custom_minimum_size = Vector2(UIStyle.px(300), UIStyle.px(26))
	buttons.add_child(play)
	buttons.add_child(UIStyle.button("MENU", _on_menu, 10))
	play.grab_focus.call_deferred()


func _build_round(index: int) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	col.add_theme_constant_override("separation", UIStyle.px(6))
	var header := UIStyle.label(Tournament.round_name_for_index(index), 10, UIStyle.COLOR_ACCENT)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(header)

	for m in Tournament.matches_in_round(index):
		var home := "TBD"
		var away := "TBD"
		var hg := -1
		var ag := -1
		var winner := ""
		var mine := false
		if index < Tournament.rounds.size():
			var f: Dictionary = Tournament.rounds[index][m]
			home = f["home"]
			away = f["away"]
			hg = f["home_goals"]
			ag = f["away_goals"]
			winner = f["winner"]
			mine = home == Tournament.player_team or away == Tournament.player_team

		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(UIStyle.px(200), UIStyle.px(40))
		panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		panel.add_theme_stylebox_override("panel", UIStyle.panel_style(UIStyle.COLOR_GOLD if mine else UIStyle.COLOR_PANEL))
		var rows := VBoxContainer.new()
		panel.add_child(rows)
		rows.add_child(_team_row(home, hg, winner != "" and winner == home))
		rows.add_child(_team_row(away, ag, winner != "" and winner == away))
		col.add_child(panel)
	return col


func _team_row(team: String, goals: int, is_winner: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UIStyle.px(4))
	var flag := UIStyle.flag_for(team)
	if flag != null:
		var icon := TextureRect.new()
		icon.texture = flag
		icon.stretch_mode = TextureRect.STRETCH_KEEP
		row.add_child(icon)
	var color := UIStyle.COLOR_ACCENT if is_winner else UIStyle.COLOR_TEXT
	var n := UIStyle.label(team, 8, color)
	n.custom_minimum_size.x = UIStyle.px(150)
	n.clip_text = true
	row.add_child(n)
	row.add_child(UIStyle.label("-" if goals < 0 else str(goals), 10, color))
	return row


func _on_menu() -> void:
	Tournament.reset()
	get_tree().change_scene_to_file(Tournament.SCENE_MENU)
