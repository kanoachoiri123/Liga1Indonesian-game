extends Control

@onready var start_button: BaseButton = %StartButton
@onready var quit_button: BaseButton = %QuitButton

func _ready() -> void:
	MusicPlayer.play_track(MusicPlayer.Track.MENU)
	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(_on_quit)
	start_button.grab_focus()

func _on_start() -> void:
	get_tree().change_scene_to_file(Tournament.SCENE_TEAM_SELECT)

func _on_quit() -> void:
	get_tree().quit()
