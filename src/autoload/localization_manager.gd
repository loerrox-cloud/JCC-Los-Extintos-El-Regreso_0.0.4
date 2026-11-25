extends Node

signal language_changed(new_lang: String)

var lang: String = "es"

const STRINGS := {
	"es": {
		"title": "LOS EXTINTOS",
		"subtitle": "EL REGRESO DEL PASADO",
		"play_ai": "Jugar vs IA",
		"play_local": "Duelo Local 1v1",
		"deck_builder": "Constructor de Mazos",
		"gallery": "Colección de Criaturas",
		"lang_btn": "Idioma: ES",
		"hp": "Vida",
		"atk": "Ataque",
		"arm": "Armadura",
		"spd": "Velocidad",
		"amber": "Ámbar",
		"vp": "PV",
		"turn": "Turno",
		"your_turn": "Tu Turno",
		"enemy_turn": "Turno Rival",
		"p1_turn": "Turno Jugador 1",
		"p2_turn": "Turno Jugador 2",
		"end_turn": "Terminar Turno",
		"draw": "Robar",
		"deck": "Mazo",
		"select_target": "Elige un objetivo...",
		"select_ally": "Elige un aliado...",
		"cancel": "Cancelar",
		"back_menu": "Menú",
		"victory": "¡VICTORIA!",
		"defeat": "DERROTA",
		"p1_wins": "¡GANA JUGADOR 1!",
		"p2_wins": "¡GANA JUGADOR 2!",
		"play_again": "Jugar de nuevo",
		"save_deck": "Guardar Mazo",
		"clear_deck": "Limpiar",
		"use_starter": "Mazo Inicial",
		"cards_count": "Cartas",
		"all": "Todas",
		"search_placeholder": "Buscar criatura...",
		"pending_art": "Arte pendiente",
		"acted": "Ya actuó",
		"flinched": "Retrocedido",
		"delay_lbl": "Retraso",
		"cd_lbl": "Recarga",
		"no_amber": "Sin Ámbar",
		"synergy": "SINERGIA",
		"resonance": "RESONANCIA",
		"bleed_roll": "Tirada de Sangrado",
		"active_deck": "Mazo activo",
		"hint_drag": "Arrastra una carta de tu mano a un hueco vacío (o haz clic en carta → hueco). Clic derecho para inspeccionar.",
		"hint_action": "Haz clic en una de tus criaturas en mesa para usar sus habilidades.",
	},
	"en": {
		"title": "EXTINCTABLES",
		"subtitle": "THE RETURN OF A PAST",
		"play_ai": "Play vs AI",
		"play_local": "Local 1v1 Duel",
		"deck_builder": "Deck Builder",
		"gallery": "Creature Collection",
		"lang_btn": "Language: EN",
		"hp": "Life",
		"atk": "Attack",
		"arm": "Armour",
		"spd": "Speed",
		"amber": "Amber",
		"vp": "VP",
		"turn": "Turn",
		"your_turn": "Your Turn",
		"enemy_turn": "Enemy Turn",
		"p1_turn": "Player 1 Turn",
		"p2_turn": "Player 2 Turn",
		"end_turn": "End Turn",
		"draw": "Draw",
		"deck": "Deck",
		"select_target": "Choose a target...",
		"select_ally": "Choose an ally...",
		"cancel": "Cancel",
		"back_menu": "Menu",
		"victory": "VICTORY!",
		"defeat": "DEFEAT",
		"p1_wins": "PLAYER 1 WINS!",
		"p2_wins": "PLAYER 2 WINS!",
		"play_again": "Play Again",
		"save_deck": "Save Deck",
		"clear_deck": "Clear",
		"use_starter": "Starter Deck",
		"cards_count": "Cards",
		"all": "All",
		"search_placeholder": "Search creature...",
		"pending_art": "Art pending",
		"acted": "Acted",
		"flinched": "Flinched",
		"delay_lbl": "Delay",
		"cd_lbl": "CD",
		"no_amber": "No Amber",
		"synergy": "SYNERGY",
		"resonance": "RESONANCE",
		"bleed_roll": "Bleed Dice Roll",
		"active_deck": "Active deck",
		"hint_drag": "Drag a card from your hand onto an empty slot (or click card → slot). Right-click to inspect.",
		"hint_action": "Click one of your board creatures to use its abilities.",
	},
}


func t(key: String) -> String:
	var table: Dictionary = STRINGS.get(lang, STRINGS["es"])
	return str(table.get(key, key))


func toggle_language() -> void:
	lang = "en" if lang == "es" else "es"
	language_changed.emit(lang)


func set_language(code: String) -> void:
	if code in ["es", "en"] and code != lang:
		lang = code
		language_changed.emit(lang)
