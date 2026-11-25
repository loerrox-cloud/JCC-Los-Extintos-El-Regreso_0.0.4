class_name PassiveData
extends Resource

@export var id: String = ""
@export var name_es: String = ""
@export var name_en: String = ""
@export var trigger: GameEnums.PassiveTrigger = GameEnums.PassiveTrigger.NONE
@export var effects: Array[EffectSpec] = []


func get_display_name(lang: String = "es") -> String:
	if lang == "en" and not name_en.is_empty():
		return name_en
	return name_es


func format_bbcode(effective_attack: int, lang: String = "es") -> String:
	var parts: PackedStringArray = PackedStringArray()
	for ef in effects:
		parts.append(AbilityData._describe_effect(ef, effective_attack, lang))
	var tag := ""
	if trigger == GameEnums.PassiveTrigger.ON_ENTER:
		tag = " al entrar" if lang != "en" else " on entry"
	elif trigger == GameEnums.PassiveTrigger.ON_COUNTER:
		tag = " al ser atacado" if lang != "en" else " on counter"
	return "[color=#d5a6ff][b]%s:[/b][/color] %s%s." % [get_display_name(lang), ", ".join(parts), tag]


static func from_dict(d: Dictionary) -> PassiveData:
	var p := PassiveData.new()
	p.id = str(d.get("id", ""))
	p.name_es = str(d.get("name_es", p.id))
	p.name_en = str(d.get("name_en", p.name_es))
	var trig_s: String = str(d.get("trigger", "NONE")).to_upper()
	if GameEnums.PassiveTrigger.has(trig_s):
		p.trigger = GameEnums.PassiveTrigger[trig_s]
	for ef_d in d.get("effects", []):
		p.effects.append(EffectSpec.from_dict(ef_d))
	return p
