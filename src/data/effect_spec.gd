class_name EffectSpec
extends Resource

@export var kind: GameEnums.EffectKind = GameEnums.EffectKind.DAMAGE
@export var target: GameEnums.TargetScope = GameEnums.TargetScope.SINGLE_ENEMY
@export var value: float = 0.0
@export var duration: int = 0
@export var dice_count: int = 0
@export var dice_sides: int = 0
@export var neutral_damage: bool = false


static func from_dict(d: Dictionary) -> EffectSpec:
	var spec := EffectSpec.new()
	var k_str: String = str(d.get("kind", "DAMAGE")).to_upper()
	if GameEnums.EffectKind.has(k_str):
		spec.kind = GameEnums.EffectKind[k_str]
	var t_str: String = str(d.get("target", "SINGLE_ENEMY")).to_upper()
	if GameEnums.TargetScope.has(t_str):
		spec.target = GameEnums.TargetScope[t_str]
	spec.value = float(d.get("value", 0.0))
	spec.duration = int(d.get("duration", 0))
	spec.dice_count = int(d.get("dice_count", 0))
	spec.dice_sides = int(d.get("dice_sides", 0))
	spec.neutral_damage = bool(d.get("neutral_damage", false))
	return spec
