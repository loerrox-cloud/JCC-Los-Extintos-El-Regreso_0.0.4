class_name AbilityData
extends Resource

@export var id: String = ""
@export var name_es: String = ""
@export var name_en: String = ""
@export var is_charged: bool = false
@export var amber_cost: int = 0
@export var cooldown: int = 0
@export var initial_delay: int = 0
@export var has_priority: bool = false
@export var effects: Array[EffectSpec] = []


func get_display_name(lang: String = "es") -> String:
	if lang == "en" and not name_en.is_empty():
		return name_en
	return name_es


func needs_enemy_target() -> bool:
	for ef in effects:
		if ef.target == GameEnums.TargetScope.SINGLE_ENEMY:
			return true
	return false


func needs_ally_target() -> bool:
	for ef in effects:
		if ef.target == GameEnums.TargetScope.SINGLE_ALLY:
			return true
	return false


func format_bbcode(effective_attack: int, lang: String = "es") -> String:
	var parts: PackedStringArray = PackedStringArray()
	if has_priority:
		parts.append("[color=#ff8a5b]%s[/color]" % ("Ataca primero" if lang == "es" else "Strikes first"))
	for ef in effects:
		parts.append(_describe_effect(ef, effective_attack, lang))
	var body := ", ".join(parts)
	var meta: PackedStringArray = PackedStringArray()
	if initial_delay > 0:
		meta.append(("%d retraso" if lang == "es" else "%d delay") % initial_delay)
	if cooldown > 0:
		meta.append(("%d recarga" if lang == "es" else "%d cd") % cooldown)
	var suffix := ""
	if not meta.is_empty():
		suffix = " [color=#d4c4ff](%s)[/color]" % ", ".join(meta)
	return "[b]%s:[/b] %s.%s" % [get_display_name(lang), body, suffix]


static func _describe_effect(ef: EffectSpec, atk: int, lang: String) -> String:
	var es := lang != "en"
	var turns_txt := ("[color=#e6ff6b]%d %s[/color]" % [ef.duration, ("turno" if ef.duration == 1 else "turnos") if es else ("turn" if ef.duration == 1 else "turns")]) if ef.duration > 0 else ""
	match ef.kind:
		GameEnums.EffectKind.DAMAGE:
			var dmg: int = int(floor(float(atk) * ef.value))
			if ef.target == GameEnums.TargetScope.ALL_ENEMIES:
				return ("[color=#ff5959]%d de daño[/color] a todos" if es else "[color=#ff5959]%d dmg[/color] to all enemies") % dmg
			if ef.neutral_damage:
				return ("[color=#ff5959]%d daño neutral[/color]" if es else "[color=#ff5959]%d neutral dmg[/color]") % dmg
			return ("[color=#ff5959]%d de daño[/color]" if es else "[color=#ff5959]%d dmg[/color]") % dmg
		GameEnums.EffectKind.FLAT_DAMAGE_NEUTRAL:
			return ("[color=#ff5959]%d daño neutral[/color]" if es else "[color=#ff5959]%d neutral dmg[/color]") % int(ef.value)
		GameEnums.EffectKind.BLEED:
			var dice := "%dd%d" % [ef.dice_count, ef.dice_sides]
			return ("[color=#ff4444]%s sangrado[/color] (%s)" if es else "[color=#ff4444]%s bleed[/color] (%s)") % [dice, turns_txt]
		GameEnums.EffectKind.HEAL_MAX_HP_PCT:
			var who := _scope_label(ef.target, es)
			return ("[color=#7dff6b]cura %d%% vida[/color]%s" if es else "[color=#7dff6b]heals %d%% HP[/color]%s") % [int(ef.value), who]
		GameEnums.EffectKind.HEAL_DAMAGE_PCT:
			return ("[color=#7dff6b]cura %d%% del daño[/color]" if es else "[color=#7dff6b]heals %d%% of dmg[/color]") % int(ef.value)
		GameEnums.EffectKind.HEAL_PCT_REGEN:
			var who := _scope_label(ef.target, es)
			return ("[color=#7dff6b]regen %d%% vida[/color]%s (%s)" if es else "[color=#7dff6b]regen %d%% HP[/color]%s (%s)") % [int(ef.value), who, turns_txt]
		GameEnums.EffectKind.HEAL_FLAT_REGEN:
			return ("[color=#7dff6b]regen +%d PV[/color] (%s)" if es else "[color=#7dff6b]regen +%d HP[/color] (%s)") % [int(ef.value), turns_txt]
		GameEnums.EffectKind.MOD_ATTACK_PCT:
			var sign_s := "+" if ef.value >= 0 else ""
			var who := _scope_label(ef.target, es)
			return ("[color=#ff6e6e]%s%d%% daño[/color]%s (%s)" if es else "[color=#ff6e6e]%s%d%% atk[/color]%s (%s)") % [sign_s, int(ef.value), who, turns_txt]
		GameEnums.EffectKind.MOD_ATTACK_FLAT:
			var sign_s := "+" if ef.value >= 0 else ""
			var who := _scope_label(ef.target, es)
			return ("[color=#ff6e6e]%s%d daño[/color]%s (%s)" if es else "[color=#ff6e6e]%s%d atk[/color]%s (%s)") % [sign_s, int(ef.value), who, turns_txt]
		GameEnums.EffectKind.MOD_ARMOR_FLAT:
			var sign_s := "+" if ef.value >= 0 else ""
			var who := _scope_label(ef.target, es)
			return ("[color=#4ce8ff]%s%d armadura[/color]%s (%s)" if es else "[color=#4ce8ff]%s%d armor[/color]%s (%s)") % [sign_s, int(ef.value), who, turns_txt]
		GameEnums.EffectKind.MOD_SPEED_FLAT:
			var sign_s := "+" if ef.value >= 0 else ""
			var who := _scope_label(ef.target, es)
			return ("[color=#ffd24c]%s%d velocidad[/color]%s (%s)" if es else "[color=#ffd24c]%s%d speed[/color]%s (%s)") % [sign_s, int(ef.value), who, turns_txt]
		GameEnums.EffectKind.CLEANSE_DEBUFFS:
			if ef.target == GameEnums.TargetScope.ALL_ALLIES:
				return "[color=#88ffaa]limpia al equipo[/color]" if es else "[color=#88ffaa]cleanses team[/color]"
			return "[color=#88ffaa]limpia efectos neg.[/color]" if es else "[color=#88ffaa]cleanses debuffs[/color]"
		GameEnums.EffectKind.DISPEL_BUFFS:
			if ef.target == GameEnums.TargetScope.ALL_ENEMIES:
				return "[color=#d9a3ff]anula buffs rivales[/color]" if es else "[color=#d9a3ff]dispels all enemy buffs[/color]"
			return "[color=#d9a3ff]anula efectos pos.[/color]" if es else "[color=#d9a3ff]dispels buffs[/color]"
		GameEnums.EffectKind.DISPEL_ATK_SPD_BUFFS:
			return "[color=#d9a3ff]anula daño/vel. rival[/color]" if es else "[color=#d9a3ff]dispels atk/spd buffs[/color]"
		GameEnums.EffectKind.FLINCH:
			return ("[color=#c99cff]retrocede[/color] (%s)" if es else "[color=#c99cff]flinch[/color] (%s)") % turns_txt
		GameEnums.EffectKind.AMBER_REGEN:
			return ("[color=#ffbe42]+1 ámbar/turno[/color] (%s)" if es else "[color=#ffbe42]+1 amber/turn[/color] (%s)") % turns_txt
		GameEnums.EffectKind.AMBER_DRAIN:
			return ("[color=#ff9242]-1 ámbar rival[/color] (%s)" if es else "[color=#ff9242]-1 enemy amber[/color] (%s)") % turns_txt
		GameEnums.EffectKind.EXTRA_TURN:
			return "[color=#ffe066]turno extra[/color]" if es else "[color=#ffe066]extra turn[/color]"
	return ""


static func _scope_label(scope: GameEnums.TargetScope, es: bool) -> String:
	match scope:
		GameEnums.TargetScope.ALL_ALLIES:
			return " equipo" if es else " team"
		GameEnums.TargetScope.SINGLE_ALLY:
			return " aliado" if es else " ally"
		GameEnums.TargetScope.LOWEST_HP_ALLY:
			return " aliado más herido" if es else " lowest HP ally"
		GameEnums.TargetScope.ALL_ENEMIES:
			return " a todos" if es else " all enemies"
	return ""


static func from_dict(d: Dictionary) -> AbilityData:
	var ab := AbilityData.new()
	ab.id = str(d.get("id", ""))
	ab.name_es = str(d.get("name_es", ab.id))
	ab.name_en = str(d.get("name_en", ab.name_es))
	ab.is_charged = bool(d.get("is_charged", false))
	ab.amber_cost = int(d.get("amber_cost", 0))
	ab.cooldown = int(d.get("cooldown", 0))
	ab.initial_delay = int(d.get("initial_delay", 0))
	ab.has_priority = bool(d.get("has_priority", false))
	for ef_d in d.get("effects", []):
		ab.effects.append(EffectSpec.from_dict(ef_d))
	return ab
