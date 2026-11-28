class_name Dice
extends RefCounted

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()


func roll(count: int, sides: int) -> Dictionary:
	var rolls: Array[int] = []
	var total: int = 0
	for i in range(maxi(1, count)):
		var r: int = rng.randi_range(1, maxi(2, sides))
		rolls.append(r)
		total += r
	return {
		"count": count,
		"sides": sides,
		"rolls": rolls,
		"total": total,
	}


func shuffle_strings(arr: Array[String]) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: String = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
