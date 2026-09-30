extends RefCounted
class_name ShopProgression

var balance: Dictionary
var abilities: Dictionary = {}
var wallet := 0
var unlocked: Array = []
var slots: Array[String] = ["bass"]
var slot_count := 2
var levels: Dictionary = {"bass": 1}
var paid: Dictionary = {"bass": 0}
var stats := {"damage": 0, "attack": 0, "move": 0}
var offers: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

func _init() -> void:
	balance = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json"))
	var list: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/abilities.json"))
	for item in list:
		abilities[item.id] = item
	rng.randomize()

func damage() -> float:
	return float(balance.base_damage) + int(stats.damage)

func attack_interval() -> float:
	return maxf(float(balance.attack_floor), float(balance.attack_interval) * pow(0.9, int(stats.attack)))

func move_interval() -> float:
	return maxf(float(balance.move_floor), float(balance.move_interval) * pow(0.92, int(stats.move)))

func level(id: String) -> int:
	return int(levels.get(id, 1))

func pool(tier: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if tier == 0:
		for id in ["damage", "attack", "move"]:
			if (id == "attack" and attack_interval() <= float(balance.attack_floor)) or (id == "move" and move_interval() <= float(balance.move_floor)):
				continue
			result.append({"id": id, "kind": "stat", "tier": 0, "price": ceili(10 * pow(1.5, int(stats[id])))})
	for id in abilities:
		var data: Dictionary = abilities[id]
		if int(data.tier) != tier or (id in slots and level(id) >= 3):
			continue
		var kind := "upgrade" if id in slots else "ability"
		var base := int(balance.tier_prices[tier])
		var price := ceili(base * 0.6 * pow(1.5, level(id) - 1)) if kind == "upgrade" else base
		result.append({"id": id, "kind": kind, "tier": tier, "price": price})
	return result

func odds() -> Array[float]:
	var weights: Array[float] = []
	var total := 0.0
	for tier in range(4):
		var weight := float(balance.tier_weights[tier]) if (tier == 0 or tier in unlocked) and not pool(tier).is_empty() else 0.0
		weights.append(weight)
		total += weight
	for i in range(4):
		weights[i] = weights[i] / total if total > 0 else 0.0
	return weights

func roll() -> void:
	offers.clear()
	var chances := odds()
	var used: Array[String] = []
	for i in range(3):
		var value := rng.randf()
		var tier := 0
		var cumulative := 0.0
		for t in range(4):
			cumulative += chances[t]
			if value < cumulative:
				tier = t
				break
		var candidates := pool(tier)
		var unique: Array[Dictionary] = []
		for candidate in candidates:
			if not candidate.id in used:
				unique.append(candidate)
		if not unique.is_empty():
			candidates = unique
		if candidates.is_empty():
			continue
		var chosen: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)].duplicate()
		offers.append(chosen)
		used.append(chosen.id)

func reroll() -> bool:
	if wallet < int(balance.reroll_price):
		return false
	wallet -= int(balance.reroll_price)
	roll()
	return true

func unlock_slot() -> bool:
	if slot_count >= 4:
		return false
	var cost := int(balance.slot_prices[slot_count - 2])
	if wallet < cost:
		return false
	wallet -= cost
	slot_count += 1
	return true

func refund(index: int) -> int:
	if index < 0 or index >= slots.size():
		return 0
	return floori(float(paid.get(slots[index], 0)) * 0.5)

func buy(index: int, replace_slot: int = -1) -> bool:
	if index < 0 or index >= offers.size() or offers[index].is_empty():
		return false
	var offer := offers[index]
	var id: String = offer.id
	var price := int(offer.price)
	var replacing: bool = offer.kind == "ability" and slots.size() >= slot_count
	var credit := refund(replace_slot) if replacing else 0
	if replacing and (replace_slot < 0 or replace_slot >= slots.size()):
		return false
	if wallet + credit < price:
		return false
	if offer.kind == "upgrade" and (not id in slots or level(id) >= 3):
		return false
	if offer.kind == "ability" and id in slots:
		return false
	wallet += credit - price
	match offer.kind:
		"stat":
			stats[id] += 1
		"upgrade":
			levels[id] = level(id) + 1
		"ability":
			if replacing:
				slots[replace_slot] = id
			else:
				slots.append(id)
			paid[id] = price
			levels[id] = level(id)
	offers[index] = {}
	# Prevent stale duplicate cards after a purchase changes their meaning.
	for other in range(offers.size()):
		if not offers[other].is_empty() and offers[other].id == id:
			offers[other] = {}
	return true
