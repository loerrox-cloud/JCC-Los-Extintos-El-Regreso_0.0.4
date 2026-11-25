class_name GameEnums
extends RefCounted

enum Era {
	PALEOZOICO,
	MESOZOICO,
	CENOZOICO,
}

enum Subclass {
	TERRESTRE,
	ACUATICO,
	ANFIBIO,
	VOLADOR,
}

enum Rarity {
	BRONCE,
	PLATA,
	ORO,
}

enum TurnPhase {
	DEPLOY,
	PRIORITY,
	ATTACK,
	DISCARD,
	GAME_OVER,
}

enum TargetScope {
	SELF,
	SINGLE_ALLY,
	ALL_ALLIES,
	LOWEST_HP_ALLY,
	SINGLE_ENEMY,
	ALL_ENEMIES,
	ATTACKER,
}

enum PassiveTrigger {
	NONE,
	ON_ENTER,
	ON_COUNTER,
}

enum EffectKind {
	DAMAGE,
	BLEED,
	HEAL_MAX_HP_PCT,
	HEAL_DAMAGE_PCT,
	HEAL_FLAT_REGEN,
	HEAL_PCT_REGEN,
	MOD_ATTACK_PCT,
	MOD_ATTACK_FLAT,
	MOD_ARMOR_FLAT,
	MOD_SPEED_FLAT,
	CLEANSE_DEBUFFS,
	DISPEL_BUFFS,
	DISPEL_ATK_SPD_BUFFS,
	FLINCH,
	AMBER_REGEN,
	AMBER_DRAIN,
	EXTRA_TURN,
	FLAT_DAMAGE_NEUTRAL,
}

## Paleozoico -> Cenozoico -> Mesozoico -> Paleozoico (+15 advantage / -10 disadvantage)
static func get_era_damage_delta(attacker: Era, defender: Era, advantage_bonus: int = 15, disadvantage_penalty: int = -10) -> int:
	if attacker == defender:
		return 0
	if (attacker == Era.PALEOZOICO and defender == Era.CENOZOICO) \
			or (attacker == Era.CENOZOICO and defender == Era.MESOZOICO) \
			or (attacker == Era.MESOZOICO and defender == Era.PALEOZOICO):
		return advantage_bonus
	return disadvantage_penalty


static func parse_era(raw: String) -> Era:
	match raw.strip_edges().to_lower():
		"paleozoico", "paleozoic":
			return Era.PALEOZOICO
		"mesozoico", "mesozoic":
			return Era.MESOZOICO
		"cenozoico", "cenozoic":
			return Era.CENOZOICO
	push_warning("Unknown era '%s', defaulting to PALEOZOICO" % raw)
	return Era.PALEOZOICO


static func parse_subclass(raw: String) -> Subclass:
	match raw.strip_edges().to_lower():
		"terrestre", "terrestrial":
			return Subclass.TERRESTRE
		"acuático", "acuatico", "aquatic":
			return Subclass.ACUATICO
		"anfibio", "amphibian":
			return Subclass.ANFIBIO
		"volador", "flying":
			return Subclass.VOLADOR
	push_warning("Unknown subclass '%s', defaulting to TERRESTRE" % raw)
	return Subclass.TERRESTRE


static func parse_rarity(raw: String) -> Rarity:
	match raw.strip_edges().to_lower():
		"bronce", "bronze":
			return Rarity.BRONCE
		"plata", "silver":
			return Rarity.PLATA
		"oro", "gold":
			return Rarity.ORO
	return Rarity.BRONCE


static func era_key(era: Era) -> String:
	match era:
		Era.PALEOZOICO: return "paleozoico"
		Era.MESOZOICO: return "mesozoico"
		Era.CENOZOICO: return "cenozoico"
	return "paleozoico"


static func subclass_key(sub: Subclass) -> String:
	match sub:
		Subclass.TERRESTRE: return "terrestre"
		Subclass.ACUATICO: return "acuatico"
		Subclass.ANFIBIO: return "anfibio"
		Subclass.VOLADOR: return "volador"
	return "terrestre"


static func era_label(era: Era, lang: String = "es") -> String:
	if lang == "en":
		match era:
			Era.PALEOZOICO: return "Paleozoic"
			Era.MESOZOICO: return "Mesozoic"
			Era.CENOZOICO: return "Cenozoic"
	match era:
		Era.PALEOZOICO: return "Paleozoico"
		Era.MESOZOICO: return "Mesozoico"
		Era.CENOZOICO: return "Cenozoico"
	return ""


static func subclass_label(sub: Subclass, lang: String = "es") -> String:
	if lang == "en":
		match sub:
			Subclass.TERRESTRE: return "Terrestrial"
			Subclass.ACUATICO: return "Aquatic"
			Subclass.ANFIBIO: return "Amphibian"
			Subclass.VOLADOR: return "Flying"
	match sub:
		Subclass.TERRESTRE: return "Terrestre"
		Subclass.ACUATICO: return "Acuático"
		Subclass.ANFIBIO: return "Anfibio"
		Subclass.VOLADOR: return "Volador"
	return ""


static func rarity_label(rarity: Rarity, lang: String = "es") -> String:
	if lang == "en":
		match rarity:
			Rarity.BRONCE: return "Bronze"
			Rarity.PLATA: return "Silver"
			Rarity.ORO: return "Gold"
	match rarity:
		Rarity.BRONCE: return "Bronce"
		Rarity.PLATA: return "Plata"
		Rarity.ORO: return "Oro"
	return ""


static func rarity_color(rarity: Rarity) -> Color:
	match rarity:
		Rarity.BRONCE: return Color(0.80, 0.46, 0.22)
		Rarity.PLATA: return Color(0.78, 0.84, 0.90)
		Rarity.ORO: return Color(1.0, 0.82, 0.22)
	return Color.WHITE


static func era_color(era: Era) -> Color:
	match era:
		Era.PALEOZOICO: return Color(0.68, 0.21, 0.21)
		Era.MESOZOICO: return Color(0.45, 0.56, 0.14)
		Era.CENOZOICO: return Color(0.24, 0.65, 0.58)
	return Color.WHITE


static func subclass_color(sub: Subclass) -> Color:
	match sub:
		Subclass.TERRESTRE: return Color(0.62, 0.40, 0.20)
		Subclass.ACUATICO: return Color(0.18, 0.54, 0.92)
		Subclass.ANFIBIO: return Color(0.32, 0.78, 0.54)
		Subclass.VOLADOR: return Color(0.60, 0.86, 0.96)
	return Color.WHITE


static func rarity_rank(rarity: Rarity) -> int:
	match rarity:
		Rarity.ORO: return 3
		Rarity.PLATA: return 2
		_: return 1


static func phase_label(phase: TurnPhase, lang: String = "es") -> String:
	if lang == "en":
		match phase:
			TurnPhase.DEPLOY: return "Deploy"
			TurnPhase.PRIORITY: return "Priority"
			TurnPhase.ATTACK: return "Attack"
			TurnPhase.DISCARD: return "Discard"
			TurnPhase.GAME_OVER: return "Match Over"
	match phase:
		TurnPhase.DEPLOY: return "Despliegue"
		TurnPhase.PRIORITY: return "Prioridad"
		TurnPhase.ATTACK: return "Ataque"
		TurnPhase.DISCARD: return "Descarte"
		TurnPhase.GAME_OVER: return "Fin de Partida"
	return ""
