	class_name DamageCalculator
extends RefCounted


static func compute_damage(
		attacker: CreatureInstance,
		defender: CreatureInstance,
		multiplier: float,
		rules: GameRulesConfig,
		neutral: bool = false
) -> Dictionary:
	var eff_atk: int = attacker.get_effective_attack()
	var base_dmg: int = int(floor(float(eff_atk) * multiplier))
	var era_delta: int = 0
	if not neutral:
		era_delta = GameEnums.get_era_damage_delta(
			attacker.data.era,
			defender.data.era,
			rules.era_advantage_bonus,
			rules.era_disadvantage_penalty
		)
	var after_era: int = maxi(0, base_dmg + era_delta)
	var armor: int = defender.get_effective_armor()
	var final_dmg: int = maxi(0, after_era - armor)

	return {
		"base_damage": base_dmg,
		"era_delta": era_delta,
		"armor_mitigated": maxi(0, after_era - final_dmg),
		"final_damage": final_dmg,
	}
