class_name CreatureInstance
extends RefCounted

var uid: int = 0
var owner_id: int = 0
var slot_index: int = 0
var data: CreatureData
var current_hp: int = 0
var max_hp: int = 0
var statuses: Array[StatusEffect] = []
var ability_cooldowns: Array[int] = [0, 0]
var acted_this_turn: bool = false
var extra_turns_queued: int = 0
var summoned_round: int = 0


func _init(p_uid: int, p_owner: int, p_slot: int, p_data: CreatureData, abilities_lookup: Dictionary, p_summoned_round: int = 0) -> void:
	uid = p_uid
	owner_id = p_owner
	slot_index = p_slot
	data = p_data
	summoned_round = p_summoned_round
	max_hp = p_data.hp
	current_hp = p_data.hp
	ability_cooldowns = []
	for aid in p_data.ability_ids:
		var ab: AbilityData = abilities_lookup.get(aid, null)
		ability_cooldowns.append(ab.initial_delay if ab != null else 0)


func is_alive() -> bool:
	return current_hp > 0


func is_flinched() -> bool:
	for st in statuses:
		if st.kind == GameEnums.EffectKind.FLINCH and st.turns_left > 0:
			return true
	return false


func can_act() -> bool:
	if not is_alive() or is_flinched():
		return false
	return (not acted_this_turn) or extra_turns_queued > 0


func has_positive_buff() -> bool:
	for st in statuses:
		if st.is_positive and st.turns_left > 0:
			return true
	return false


func get_attack_pct_modifier() -> float:
	var pct: float = 0.0
	for st in statuses:
		if st.kind == GameEnums.EffectKind.MOD_ATTACK_PCT:
			pct += st.value
	return pct


func get_effective_attack() -> int:
	var pct: float = get_attack_pct_modifier()
	var flat: int = 0
	for st in statuses:
		if st.kind == GameEnums.EffectKind.MOD_ATTACK_FLAT:
			flat += int(st.value)
	var scaled: int = int(floor(float(data.attack) * maxf(0.0, 1.0 + pct / 100.0)))
	return maxi(0, scaled + flat)


func get_effective_armor() -> int:
	var delta: int = 0
	for st in statuses:
		if st.kind == GameEnums.EffectKind.MOD_ARMOR_FLAT:
			delta += int(st.value)
	return maxi(0, data.armor + delta)


func get_effective_speed() -> int:
	var delta: int = 0
	for st in statuses:
		if st.kind == GameEnums.EffectKind.MOD_SPEED_FLAT:
			delta += int(st.value)
	return maxi(1, data.speed + delta)


func add_status(st: StatusEffect) -> bool:
	# Flinch (Retroceso) does not stack
	if st.kind == GameEnums.EffectKind.FLINCH:
		if is_flinched():
			return false
	statuses.append(st)
	return true


## Cleanse removes all negative statuses EXCEPT Flinch
func cleanse_debuffs() -> int:
	var removed: int = 0
	var kept: Array[StatusEffect] = []
	for st in statuses:
		if not st.is_positive and st.kind != GameEnums.EffectKind.FLINCH:
			removed += 1
		else:
			kept.append(st)
	statuses = kept
	return removed


## Dispel removes all positive statuses EXCEPT regenerative healing
func dispel_buffs() -> int:
	var removed: int = 0
	var kept: Array[StatusEffect] = []
	for st in statuses:
		if st.is_positive and st.kind != GameEnums.EffectKind.HEAL_PCT_REGEN and st.kind != GameEnums.EffectKind.HEAL_FLAT_REGEN:
			removed += 1
		else:
			kept.append(st)
	statuses = kept
	return removed


## Used by Embestida: removes only Attack and Speed positive buffs
func dispel_atk_spd_buffs() -> int:
	var removed: int = 0
	var kept: Array[StatusEffect] = []
	for st in statuses:
		if st.is_positive and (st.kind == GameEnums.EffectKind.MOD_ATTACK_PCT or st.kind == GameEnums.EffectKind.MOD_ATTACK_FLAT or st.kind == GameEnums.EffectKind.MOD_SPEED_FLAT):
			removed += 1
		else:
			kept.append(st)
	statuses = kept
	return removed


func heal(amount: int) -> int:
	if not is_alive() or amount <= 0:
		return 0
	var before: int = current_hp
	current_hp = mini(max_hp, current_hp + amount)
	return current_hp - before


func take_damage(amount: int) -> int:
	if not is_alive() or amount <= 0:
		return 0
	var dealt: int = mini(current_hp, amount)
	current_hp -= dealt
	return dealt


func tick_cooldowns_on_turn_start() -> void:
	acted_this_turn = false
	for i in range(ability_cooldowns.size()):
		if ability_cooldowns[i] > 0:
			ability_cooldowns[i] -= 1


func tick_statuses_on_turn_end() -> void:
	var remaining: Array[StatusEffect] = []
	for st in statuses:
		st.turns_left -= 1
		if st.turns_left > 0:
			remaining.append(st)
	statuses = remaining
