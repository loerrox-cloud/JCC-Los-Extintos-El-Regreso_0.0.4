class_name CreatureData
extends Resource

@export var id: String = ""
@export var display_name_es: String = ""
@export var display_name_en: String = ""
@export var era: GameEnums.Era = GameEnums.Era.PALEOZOICO
@export var subclass: GameEnums.Subclass = GameEnums.Subclass.TERRESTRE
@export var rarity: GameEnums.Rarity = GameEnums.Rarity.BRONCE
@export var amber_cost: int = 3
@export var hp: int = 60
@export var attack: int = 40
@export var armor: int = 0
@export var speed: int = 50
@export var ability_ids: Array[String] = []
@export var passive_id: String = ""

@export var art_normal_path: String = ""
@export var art_glow_path: String = ""
@export var background_path: String = ""
@export var art_offset: Vector2 = Vector2.ZERO
@export var art_scale: float = 1.0
@export var text_bottom_offset: float = 0.0
@export var has_custom_art: bool = false


func get_display_name(lang: String = "es") -> String:
	if lang == "en" and not display_name_en.is_empty():
		return display_name_en
	return display_name_es


static func from_dict(d: Dictionary) -> CreatureData:
	var c := CreatureData.new()
	c.id = str(d.get("id", ""))
	c.display_name_es = str(d.get("name_es", c.id))
	c.display_name_en = str(d.get("name_en", c.display_name_es))
	c.era = GameEnums.parse_era(str(d.get("era", "Paleozoico")))
	c.subclass = GameEnums.parse_subclass(str(d.get("subclass", "Terrestre")))
	c.rarity = GameEnums.parse_rarity(str(d.get("rarity", "Bronce")))
	c.amber_cost = int(d.get("amber_cost", 3))
	c.hp = int(d.get("hp", 60))
	c.attack = int(d.get("attack", 40))
	c.armor = int(d.get("armor", 0))
	c.speed = int(d.get("speed", 50))
	for aid in d.get("abilities", []):
		c.ability_ids.append(str(aid))
	c.passive_id = str(d.get("passive", ""))
	c.art_normal_path = str(d.get("art_normal", ""))
	c.art_glow_path = str(d.get("art_glow", ""))
	c.background_path = str(d.get("background", ""))
	c.has_custom_art = not c.art_normal_path.is_empty()
	return c
