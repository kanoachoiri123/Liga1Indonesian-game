extends Node

const SQUADS_PATH := "res://assets/json/squads.json"

var squads: Dictionary = {}

func _ready() -> void:
	var file := FileAccess.open(SQUADS_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open " + SQUADS_PATH)
		return
	var json_text := file.get_as_text()
	file.close()

	# Remove trailing commas, which strict JSON does not allow
	var regex := RegEx.new()
	regex.compile(",(\\s*[}\\]])")
	json_text = regex.sub(json_text, "$1", true)

	var json := JSON.new()
	var error := json.parse(json_text)
	if error != OK:
		push_error("Could not parse squads.json: " + json.get_error_message() + " at line " + str(json.get_error_line()))
		return

	var teams: Array = json.data
	for team in teams:
		var country: String = team["country"]
		var players: Array = team["players"]
		if not squads.has(country):
			squads[country] = []
		for p in players:
			var resource := PlayerResource.new(
				p["name"],
				int(p["skin"]) as Player.SkinColor,
				int(p["role"]) as Player.Role,
				float(p["speed"]),
				float(p["power"])
			)
			squads[country].append(resource)
		assert(squads[country].size() == 6, "Each squad needs exactly 6 players")

func get_squad(country: String) -> Array:
	return squads.get(country, [])
