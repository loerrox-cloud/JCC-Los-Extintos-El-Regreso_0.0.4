extends Node

const GAME_DATA_PATH := "res://data/game_data.json"

var creatures: Dictionary = {} # String id -> CreatureData
var creatures_ordered: Array[CreatureData] = []
var abilities: Dictionary = {} # String id -> AbilityData
var passives: Dictionary = {} # String id -> PassiveData
var starter_decks: Array[Dictionary] = []

var _texture_cache: Dictionary = {}


func _ready() -> void:
	load_database()


func load_database() -> void:
	creatures.clear()
	creatures_ordered.clear()
	abilities.clear()
	passives.clear()
	starter_decks.clear()

	if not FileAccess.file_exists(GAME_DATA_PATH):
		push_error("CardDatabase: Missing %s" % GAME_DATA_PATH)
		return

	var raw_text := FileAccess.get_file_as_string(GAME_DATA_PATH)
	var parsed: Variant = JSON.parse_string(raw_text)
	if not (parsed is Dictionary):
		push_error("CardDatabase: Failed to parse %s" % GAME_DATA_PATH)
		return

	var root: Dictionary = parsed
	for ab_d in root.get("abilities", []):
		var ab := AbilityData.from_dict(ab_d)
		abilities[ab.id] = ab

	for pa_d in root.get("passives", []):
		var pa := PassiveData.from_dict(pa_d)
		passives[pa.id] = pa

	for cr_d in root.get("creatures", []):
		var cr := CreatureData.from_dict(cr_d)
		creatures[cr.id] = cr
		creatures_ordered.append(cr)

	for dk in root.get("starter_decks", []):
		starter_decks.append(dk)


func get_creature(id: String) -> CreatureData:
	return creatures.get(id, null)


func get_ability(id: String) -> AbilityData:
	return abilities.get(id, null)


func get_passive(id: String) -> PassiveData:
	if id.is_empty():
		return null
	return passives.get(id, null)


func get_all_creatures(only_with_art: bool = false) -> Array[CreatureData]:
	if not only_with_art:
		return creatures_ordered
	var res: Array[CreatureData] = []
	for c in creatures_ordered:
		if c.has_custom_art:
			res.append(c)
	return res


func get_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if _texture_cache.has(path):
		return _texture_cache[path]
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		_texture_cache[path] = tex
		return tex
	return null


func get_frame_texture(sub: GameEnums.Subclass) -> Texture2D:
	return get_texture("res://assets/art/frames/frame_%s.png" % GameEnums.subclass_key(sub))


func get_era_overlay_texture(era: GameEnums.Era) -> Texture2D:
	return get_texture("res://assets/art/frames/era_overlay_%s.png" % GameEnums.era_key(era))


func get_subclass_overlay_texture(sub: GameEnums.Subclass) -> Texture2D:
	return get_texture("res://assets/art/frames/sub_overlay_%s.png" % GameEnums.subclass_key(sub))


func get_card_back_texture(lang: String = "es") -> Texture2D:
	var code := "en" if lang == "en" else "es"
	return get_texture("res://assets/art/frames/card_back_%s.jpg" % code)


func get_amber_icon(vivid: bool = false) -> Texture2D:
	if vivid:
		return get_texture("res://assets/art/icons/amber_dna_vivid.png")
	return get_texture("res://assets/art/icons/amber_dna.png")


func get_amber_cost_texture() -> Texture2D:
	return get_texture("res://assets/art/icons/amber_cost.png")
