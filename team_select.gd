extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	MusicPlayer.play_track(MusicPlayer.Track.MENU)
	UIStyle.add_background(self, UIStyle.find_asset(UIStyle.TEAMSEL_DIR, "team-selection-bac"))

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UIStyle.px(10))
	center.add_child(box)

	var heading := UIStyle.find_texture(UIStyle.TEAMSEL_DIR, "select-team-label")
	if heading != null:
		box.add_child(UIStyle.image_node(heading))
	else:
		var t := UIStyle.label("CHOOSE YOUR TEAM", 22, UIStyle.COLOR_ACCENT)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(t)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", UIStyle.px(6))
	grid.add_theme_constant_override("v_separation", UIStyle.px(6))
	box.add_child(grid)

	var first: Button = null
	for team in DataLoader.squads.keys():
		var b := UIStyle.button(team, _on_team_chosen.bind(team), 10)
		b.custom_minimum_size = Vector2(UIStyle.px(170), UIStyle.px(26))
		b.clip_text = true
		var flag := UIStyle.flag_for(team)
		if flag != null:
			b.icon = flag
		grid.add_child(b)
		if first == null:
			first = b

	var back := UIStyle.button("BACK", func(): get_tree().change_scene_to_file(Tournament.SCENE_MENU), 10)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(back)
	if first != null:
		first.grab_focus.call_deferred()


func _on_team_chosen(team: String) -> void:
	Tournament.start_tournament(team)
	get_tree().change_scene_to_file(Tournament.SCENE_BRACKET)
