extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Victory ONLY when the final has been won
	var champion := Tournament.status == Tournament.Status.CHAMPION
	MusicPlayer.play_track(MusicPlayer.Track.WIN if champion else MusicPlayer.Track.MENU)
	UIStyle.add_background(self, UIStyle.find_asset(UIStyle.TEAMSEL_DIR, "tournament-screen"))

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UIStyle.px(10))
	center.add_child(box)

	if champion:
		var wl := UIStyle.find_texture(UIStyle.TEAMSEL_DIR, "winner-label")
		if wl != null:
			box.add_child(UIStyle.image_node(wl))
		var flag := UIStyle.flag_for(Tournament.player_team)
		if flag != null:
			box.add_child(UIStyle.image_node(flag))

	var head := UIStyle.label("CONGRATULATIONS!" if champion else "UNLUCKY!", 24, UIStyle.COLOR_ACCENT)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(head)
	var msg := UIStyle.label("You've won the tournament!" if champion else "Your tournament journey ends here.", 12)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(msg)
	if Tournament.last_match_text != "":
		var d := UIStyle.label("%s: %s" % [Tournament.last_round_name, Tournament.last_match_text], 9)
		d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(d)

	var again := UIStyle.button("TOURNAMENT", _on_again, 10)
	box.add_child(again)
	box.add_child(UIStyle.button("QUIT", _on_quit, 10))
	again.grab_focus.call_deferred()


func _on_again() -> void:
	Tournament.reset()
	get_tree().change_scene_to_file(Tournament.SCENE_TEAM_SELECT)

func _on_quit() -> void:
	Tournament.reset()
	get_tree().change_scene_to_file(Tournament.SCENE_MENU)
