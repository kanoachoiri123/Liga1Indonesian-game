extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	MusicPlayer.play_track(MusicPlayer.Track.MENU)
	var bg := UIStyle.find_asset(UIStyle.MENU_DIR, "main_menu_bg")
	if bg == "":
		bg = UIStyle.find_asset(UIStyle.MENU_DIR, "menu-background")
	UIStyle.add_background(self, bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UIStyle.px(14))
	center.add_child(box)

	var title := UIStyle.label(UIStyle.GAME_TITLE, 22, UIStyle.COLOR_ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var start := UIStyle.button("TOURNAMENT", func(): get_tree().change_scene_to_file(Tournament.SCENE_TEAM_SELECT))
	box.add_child(start)
	box.add_child(UIStyle.button("QUIT", func(): get_tree().quit()))
	start.grab_focus.call_deferred()
