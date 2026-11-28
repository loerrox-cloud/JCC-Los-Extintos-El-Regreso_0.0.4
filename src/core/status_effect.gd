class_name StatusEffect
extends RefCounted

var kind: GameEnums.EffectKind
var value: float = 0.0
var turns_left: int = 1
var dice_count: int = 0
var dice_sides: int = 0
var is_positive: bool = true
var source_name: String = ""


func _init(
		p_kind: GameEnums.EffectKind = GameEnums.EffectKind.MOD_ATTACK_PCT,
		p_value: float = 0.0,
		p_turns: int = 1,
		p_dice_count: int = 0,
		p_dice_sides: int = 0,
		p_source: String = ""
) -> void:
	kind = p_kind
	value = p_value
	turns_left = p_turns
	dice_count = p_dice_count
	dice_sides = p_dice_sides
	source_name = p_source
	is_positive = _compute_is_positive()


func _compute_is_positive() -> bool:
	match kind:
		GameEnums.EffectKind.BLEED, GameEnums.EffectKind.FLINCH:
			return false
		GameEnums.EffectKind.HEAL_PCT_REGEN, GameEnums.EffectKind.HEAL_FLAT_REGEN:
			return true
		GameEnums.EffectKind.MOD_ATTACK_PCT, GameEnums.EffectKind.MOD_ATTACK_FLAT, \
				GameEnums.EffectKind.MOD_ARMOR_FLAT, GameEnums.EffectKind.MOD_SPEED_FLAT:
			return value >= 0.0
	return true


func short_badge(lang: String = "es") -> String:
	match kind:
		GameEnums.EffectKind.BLEED:
			return "🩸%dd%d(%d)" % [dice_count, dice_sides, turns_left]
		GameEnums.EffectKind.FLINCH:
			return ("💫Retr." if lang != "en" else "💫Flinch")
		GameEnums.EffectKind.HEAL_PCT_REGEN:
			return "💚+%d%%(%d)" % [int(value), turns_left]
		GameEnums.EffectKind.HEAL_FLAT_REGEN:
			return "💚+%d(%d)" % [int(value), turns_left]
		GameEnums.EffectKind.MOD_ATTACK_PCT:
			var s := "+" if value >= 0 else ""
			return "⚔%s%d%%(%d)" % [s, int(value), turns_left]
		GameEnums.EffectKind.MOD_ATTACK_FLAT:
			var s := "+" if value >= 0 else ""
			return "⚔%s%d(%d)" % [s, int(value), turns_left]
		GameEnums.EffectKind.MOD_ARMOR_FLAT:
			var s := "+" if value >= 0 else ""
			return "🛡%s%d(%d)" % [s, int(value), turns_left]
		GameEnums.EffectKind.MOD_SPEED_FLAT:
			var s := "+" if value >= 0 else ""
			return "⚡%s%d(%d)" % [s, int(value), turns_left]
	return ""
