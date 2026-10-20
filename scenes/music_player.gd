extends AudioStreamPlayer

enum Track {NONE, MENU, GAMEPLAY, TOURNAMENT, WIN}

const TRACKS := {
	Track.MENU: "res://assets/music/finalmixedmasteredshi.mp3",
	Track.GAMEPLAY: "res://assets/music/gameplay.mp3",
	Track.TOURNAMENT: "res://assets/music/tournament.mp3",
	Track.WIN: "res://assets/music/win.mp3",
}
const VOLUME_DB := {
	Track.MENU: 0.0,
	Track.GAMEPLAY: -6.0,
	Track.TOURNAMENT: 0.0,
	Track.WIN: 0.0,
}

var current := Track.NONE

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS    # keeps playing while a goal pauses the game
	play_track(Track.MENU)

# Safe to call from every screen: does nothing if that track is already playing
func play_track(track: Track) -> void:
	if track == current and playing:
		return
	var path: String = TRACKS.get(track, "")
	if path == "" or not ResourceLoader.exists(path):
		push_warning("MusicPlayer: missing " + path)
		return
	var s := load(path) as AudioStream
	if "loop" in s:
		s.loop = (track != Track.WIN)           # menu, match and tournament loop; the win jingle plays once
	stream = s
	volume_db = VOLUME_DB.get(track, 0.0)
	current = track
	play()

# Kept so older calls still work
func ensure_playing() -> void:
	if not playing:
		play_track(Track.MENU)

func set_in_match(in_match: bool) -> void:
	if in_match:
		play_track(Track.GAMEPLAY)
