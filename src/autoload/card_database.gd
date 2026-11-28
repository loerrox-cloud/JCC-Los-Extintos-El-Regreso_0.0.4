extends Node

signal database_reloaded()

const GAME_DATA_PATH := "res://data/game_data.json"
const CUSTOM_CARDS_PATH := "user://custom_cards.json"

var creatures: Dictionary = {} # String id -> CreatureData
var creatures_ordered: Array[CreatureData] = []
var abilities: Dictionary = {} # String id -> AbilityData
var passives: Dictionary = {} # String id -> PassiveData
var starter_decks: Array[Dictionary] = []
var custom_creature_ids: Dictionary = {} # String id -> true

var _texture_cache: Dictionary = {}


func _ready() -> void:
	load_database()


func load_database() -> void:
	creatures.clear()
	creatures_ordered.clear()
	abilities.clear()
	passives.clear()
	starter_decks.clear()
	custom_creature_ids.clear()

	if not FileAccess.file_exists(GAME_DATA_PATH):
		push_error("CardDatabase: Missing %s" % GAME_DATA_PATH)
		return

	var raw_text := FileAccess.get_file_as_string(GAME_DATA_PATH)
	var parsed: Variant = JSON.parse_string(raw_text)
	if not (parsed is Dictionary):
		push_error("CardDatabase: Failed to parse %s" % GAME_DATA_PATH)
		return

	_merge_data_dictionary(parsed as Dictionary, false)
	_load_custom_cards()
	database_reloaded.emit()


## Merges an official or custom JSON dictionary into the in-memory database.
func _merge_data_dictionary(root: Dictionary, is_custom: bool) -> void:
	for ab_d in root.get("abilities", []):
		if ab_d is Dictionary:
			var ab := AbilityData.from_dict(ab_d)
			if not ab.id.is_empty():
				abilities[ab.id] = ab

	for pa_d in root.get("passives", []):
		if pa_d is Dictionary:
			var pa := PassiveData.from_dict(pa_d)
			if not pa.id.is_empty():
				passives[pa.id] = pa

	for cr_d in root.get("creatures", []):
		if cr_d is Dictionary:
			var cr := CreatureData.from_dict(cr_d)
			if cr.id.is_empty():
				continue
			var existed := creatures.has(cr.id)
			creatures[cr.id] = cr
			if existed:
				for i in range(creatures_ordered.size()):
					if creatures_ordered[i].id == cr.id:
						creatures_ordered[i] = cr
						break
			else:
				creatures_ordered.append(cr)
			if is_custom:
				custom_creature_ids[cr.id] = true

	if not is_custom:
		for dk in root.get("starter_decks", []):
			starter_decks.append(dk)


## Loads optional user-created/edited cards from user://custom_cards.json without touching official data.
## On first run, generates a clean starter template so players can add custom cards directly in Notepad.
func _load_custom_cards() -> void:
	if not FileAccess.file_exists(CUSTOM_CARDS_PATH):
		_ensure_custom_cards_template()
		return
	var raw_text := FileAccess.get_file_as_string(CUSTOM_CARDS_PATH)
	var parsed: Variant = JSON.parse_string(raw_text)
	if parsed is Dictionary:
		_merge_data_dictionary(parsed as Dictionary, true)
	else:
		push_warning("CardDatabase: Ignored malformed %s" % CUSTOM_CARDS_PATH)


## Creates a documented empty template at user://custom_cards.json if none exists yet.
func _ensure_custom_cards_template() -> void:
	var template := {
		"_instrucciones": "Anade tus criaturas, habilidades o pasivas personalizadas dentro de las listas 'creatures', 'abilities' o 'passives' siguiendo el formato de '_ejemplo_criatura'. Para usar una imagen propia pon 'user://mi_imagen.png' en 'art_normal'.",
		"_ejemplo_criatura": {
			"id": "mi_criatura_custom",
			"name_es": "Mi Criatura",
			"name_en": "My Creature",
			"era": "Mesozoico",
			"subclass": "Terrestre",
			"rarity": "Plata",
			"amber_cost": 4,
			"hp": 90,
			"attack": 50,
			"armor": 10,
			"speed": 55,
			"abilities": ["mordisco", "embestida"],
			"passive": "",
			"art_normal": "",
			"art_glow": "",
			"background": "res://assets/art/backgrounds/bg_terrestre_01.jpg",
		},
		"abilities": [],
		"passives": [],
		"creatures": [],
	}
	var f := FileAccess.open(CUSTOM_CARDS_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(template, "\t"))
		f.close()


## Opens the user:// folder in the OS file explorer (handy for a button in an Options menu).
func open_custom_cards_folder() -> void:
	if not FileAccess.file_exists(CUSTOM_CARDS_PATH):
		_ensure_custom_cards_template()
	OS.shell_open(ProjectSettings.globalize_path("user://"))


## Returns the raw custom cards JSON structure so an editor can add/edit/remove entries cleanly.
func get_custom_cards_raw() -> Dictionary:
	if FileAccess.file_exists(CUSTOM_CARDS_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CUSTOM_CARDS_PATH))
		if parsed is Dictionary:
			var d := parsed as Dictionary
			if not d.has("abilities"): d["abilities"] = []
			if not d.has("passives"): d["passives"] = []
			if not d.has("creatures"): d["creatures"] = []
			return d
	return {"abilities": [], "passives": [], "creatures": []}


## Persists custom cards to user://custom_cards.json and reloads the database in memory.
func save_custom_cards(custom_data: Dictionary) -> bool:
	var f := FileAccess.open(CUSTOM_CARDS_PATH, FileAccess.WRITE)
	if f == null:
		push_error("CardDatabase: Could not write %s" % CUSTOM_CARDS_PATH)
		return false
	f.store_string(JSON.stringify(custom_data, "\t"))
	f.close()
	load_database()
	return true


func is_custom_creature(id: String) -> bool:
	return custom_creature_ids.has(id)


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
	if path.begins_with("user://") and FileAccess.file_exists(path):
		var img := Image.load_from_file(path)
		if img != null:
			var itex := ImageTexture.create_from_image(img)
			_texture_cache[path] = itex
			return itex
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
