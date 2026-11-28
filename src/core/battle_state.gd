class_name BattleState
extends RefCounted

var rules: GameRulesConfig
var round_number: int = 0 # 0 = Turno Inicial, 1+ = Turno 1, 2, ...
var turn_number: int = 0 # Alias kept in sync with round_number
var phase: GameEnums.TurnPhase = GameEnums.TurnPhase.DEPLOY
var active_player: int = 0
var first_deployer: int = 0
var deploy_step: int = 0 # 0 = first deployer, 1 = second deployer
var attack_order: Array[int] = [0, 1] # [0] = faster team, [1] = slower team
var attack_step: int = 0 # 0 = faster team attacking, 1 = slower team attacking
var discard_queue: Array[int] = [] # players needing to discard down to max_hand_size
var winner: int = -1
var next_uid: int = 1

## Each element is a Dictionary for player 0 and player 1
var players: Array[Dictionary] = []


func _init(p_rules: GameRulesConfig) -> void:
	rules = p_rules
	players.clear()
	for pid in range(2):
		var slots: Array = []
		slots.resize(rules.max_board_slots)
		for i in range(rules.max_board_slots):
			slots[i] = null
		players.append({
			"id": pid,
			"amber": rules.starting_amber,
			"victory_points": 0,
			"deck": [] as Array[String],
			"hand": [] as Array[String],
			"discard": [] as Array[String],
			"board": slots,
			"amber_modifiers": [] as Array[Dictionary], # {delta: int, turns_left: int}
			"triggered_synergies": {}, # subclass -> max tier triggered (0, 2, 3)
		})


func alloc_uid() -> int:
	var id := next_uid
	next_uid += 1
	return id


func get_player(pid: int) -> Dictionary:
	return players[pid]


func get_opponent_id(pid: int) -> int:
	return 1 - pid


func get_living_creatures(pid: int) -> Array[CreatureInstance]:
	var res: Array[CreatureInstance] = []
	for slot in players[pid]["board"]:
		if slot is CreatureInstance and slot.is_alive():
			res.append(slot)
	return res


func find_creature(uid: int) -> CreatureInstance:
	for pid in range(2):
		for slot in players[pid]["board"]:
			if slot is CreatureInstance and slot.uid == uid:
				return slot
	return null


func count_subclass_on_board(pid: int, sub: GameEnums.Subclass) -> int:
	var c := 0
	for cr in get_living_creatures(pid):
		if cr.data.subclass == sub:
			c += 1
	return c


func get_amber_extraction_delta(pid: int) -> int:
	var total := 0
	for m in players[pid]["amber_modifiers"]:
		total += int(m["delta"])
	return total


## Total combined Speed of all living creatures on `pid`'s board (including active modifiers)
func get_team_speed(pid: int) -> int:
	var total := 0
	for cr in get_living_creatures(pid):
		total += cr.get_effective_speed()
	return total


## Returns Vector2i(highest_rarity_rank, total_rarity_rank_sum) for Speed tie-breaking
func get_team_rarity_score(pid: int) -> Vector2i:
	var best := 0
	var total := 0
	for cr in get_living_creatures(pid):
		var r := GameEnums.rarity_rank(cr.data.rarity)
		best = maxi(best, r)
		total += r
	return Vector2i(best, total)


## Returns Vector2i(earliest_summoned_round, total_rounds_on_board) for team-level Tenure tie-breaking.
## Lower x (summoned earlier) or higher y (longer total board tenure) wins!
func get_team_tenure_score(pid: int) -> Vector2i:
	var living := get_living_creatures(pid)
	if living.is_empty():
		return Vector2i(999999, 0)
	var earliest := 999999
	var total_age := 0
	for cr in living:
		earliest = mini(earliest, cr.summoned_round)
		total_age += maxi(0, round_number - cr.summoned_round) + 1
	return Vector2i(earliest, total_age)


## Official deterministic tie-breaker between creatures (returns true if `a` acts BEFORE `b`):
## 1) Higher effective Speed
## 2) Higher Rarity (Oro > Plata > Bronce)
## 3) Longer on battlefield (smaller summoned_round)
## 4) Right-to-left board slot (Slot III=2 -> Slot II=1 -> Slot I=0)
static func compare_creatures_for_attack(a: CreatureInstance, b: CreatureInstance) -> bool:
	var sa := a.get_effective_speed()
	var sb := b.get_effective_speed()
	if sa != sb:
		return sa > sb
	var ra := GameEnums.rarity_rank(a.data.rarity)
	var rb := GameEnums.rarity_rank(b.data.rarity)
	if ra != rb:
		return ra > rb
	if a.summoned_round != b.summoned_round:
		return a.summoned_round < b.summoned_round
	if a.slot_index != b.slot_index:
		return a.slot_index > b.slot_index
	return a.uid < b.uid


## Returns all ready living creatures of `pid` sorted in strict official attack order.
func get_ordered_ready_creatures(pid: int) -> Array[CreatureInstance]:
	var ready: Array[CreatureInstance] = []
	for cr in get_living_creatures(pid):
		if cr.can_act():
			ready.append(cr)
	ready.sort_custom(BattleState.compare_creatures_for_attack)
	return ready


## Picks the next creature that must act under SPEED_STRICT order.
func get_fastest_ready_creature(pid: int) -> CreatureInstance:
	var ordered := get_ordered_ready_creatures(pid)
	return ordered[0] if not ordered.is_empty() else null
