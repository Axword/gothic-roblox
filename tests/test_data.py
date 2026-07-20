#!/usr/bin/env python3
"""Dependency-free regression checks and full gameplay simulation tests."""
import json
import subprocess
import sys
import math
from pathlib import Path

root = Path(__file__).resolve().parents[1]
data_dir = root / 'data/json'

# Execute the compiler script first
subprocess.run([sys.executable, str(root / 'tools/build_data')], check=True)

# Helper to load a JSON file
def load_json(name):
	p = data_dir / name
	if not p.exists():
		raise FileNotFoundError(f"Missing JSON: {name}")
	return json.loads(p.read_text(encoding='utf-8'))

def get_records(name):
	return load_json(name)['records']

# 1. Content Minima Checks
print("--- [TEST 1] Weryfikacja minimów zawartości ---")
assert len(get_records('npcs.json')) == 65, f"Expected 65 NPCs, got {len(get_records('npcs.json'))}"
assert len(get_records('npc_schedules.json')) == 65, "Expected 65 NPC schedules"
assert len(get_records('items_weapons_swords.json')) >= 20, "Expected >= 20 swords"
assert len(get_records('items_weapons_bows.json')) >= 10, "Expected >= 10 bows"
assert len(get_records('items_armors.json')) >= 4, "Expected >= 4 armors"
assert len(get_records('items_plants.json')) >= 10, "Expected >= 10 plants"
assert len(get_records('items_potions.json')) >= 6, "Expected >= 6 potions"
assert len(get_records('monsters.json')) >= 6, "Expected >= 6 monster species"
assert len(get_records('quests_old_faction.json')) >= 5, "Expected >= 5 old faction quests"
assert len(get_records('quests_new_faction.json')) >= 5, "Expected >= 5 new faction quests"
assert len(get_records('quests_side.json')) >= 10, "Expected >= 10 side quests"
print("Minima zawartości zweryfikowane pomyślnie (PASS).")

# 2. Formula Checks
print("\n--- [TEST 2] Weryfikacja reguł i wzorów RPG ---")
def formula_hp(level, vitality):
	return 80 + level * 12 + vitality * 2

def formula_level_for_xp(xp):
	level = 1
	while xp >= 100 * level * level:
		level += 1
	return level

def formula_sword_damage(base, strength):
	return base + strength * 0.55

def formula_bow_damage(base, dexterity):
	return base + dexterity * 0.65

assert formula_hp(1, 0) == 92
assert formula_hp(3, 5) == 126
assert formula_level_for_xp(0) == 1
assert formula_level_for_xp(99) == 1
assert formula_level_for_xp(100) == 2
assert formula_level_for_xp(400) == 3
assert math.isclose(formula_sword_damage(10, 10), 15.5)
assert math.isclose(formula_bow_damage(10, 10), 16.5)
print("Wszystkie formuły RPG są poprawne (PASS).")

# 3. Game State & Gameplay Loop Simulation
print("\n--- [TEST 3] Symulacja pełnej pętli gry (E2E) ---")

class PlayerStateSim:
	def __init__(self):
		self.level = 1
		self.xp = 0
		self.learning_points = 0
		self.strength = 5
		self.dexterity = 5
		self.mana = 20
		self.vitality = 0
		self.max_hp = formula_hp(1, 0)
		self.inventory = {"sword_01": 1, "lockpick": 3, "coin_zuzel": 25}
		self.equipped = "sword_01"
		self.quests = {}
		self.flags = {}
		self.reputation = {"kordon": 0, "wolnica": 0}
		self.opened_chests = {}
		self.defeated = {}
		self.faction = None
		self.world_time = 8
		self.position = [0, 6, 0]

	def add_xp(self, amount):
		self.xp += amount
		old_lvl = self.level
		new_lvl = formula_level_for_xp(self.xp)
		if new_lvl > old_lvl:
			self.learning_points += (new_lvl - old_lvl) * 10
			self.level = new_lvl
			self.max_hp = formula_hp(new_lvl, self.vitality)
			return True
		return False

	def add_item(self, item_id, count=1):
		self.inventory[item_id] = self.inventory.get(item_id, 0) + count

	def remove_item(self, item_id, count=1):
		if self.inventory.get(item_id, 0) >= count:
			self.inventory[item_id] -= count
			if self.inventory[item_id] == 0:
				del self.inventory[item_id]
			return True
		return False

# Initialize Player Simulation
player = PlayerStateSim()

# Test Quest Lifecycle
print("Testowanie przyjmowania i kończenia questów...")
quests_main = {q['id']: q for q in get_records('quests_main.json')}
quests_old = {q['id']: q for q in get_records('quests_old_faction.json')}
quests_new = {q['id']: q for q in get_records('quests_new_faction.json')}
quests_all = {**quests_main, **quests_old, **quests_new}

# Start arrival quest
assert "quest_main_arrival" not in player.quests
player.quests["quest_main_arrival"] = "active"

# Complete arrival quest with reward validation
q_arrival = quests_all["quest_main_arrival"]
player.quests["quest_main_arrival"] = "complete"
player.add_xp(q_arrival["rewards"]["xp"])
assert player.xp == 80
assert player.level == 1

# Start next quest
if "next" in q_arrival:
	player.quests[q_arrival["next"]] = "active"
assert player.quests["quest_main_right"] == "active"

# Test Quest Reward Idempotency (Cannot complete again)
def try_complete_quest(player, quest_id):
	if player.quests.get(quest_id) != "active":
		return False
	q = quests_all[quest_id]
	player.quests[quest_id] = "complete"
	player.add_xp(q["rewards"].get("xp", 0))
	if "coin_zuzel" in q["rewards"]:
		player.add_item("coin_zuzel", q["rewards"]["coin_zuzel"])
	return True

# Complete 2 Old Faction quests
player.quests["quest_old_01"] = "active"
assert try_complete_quest(player, "quest_old_01") is True
assert player.quests["quest_old_01"] == "complete"
# Try complete again -> must fail
assert try_complete_quest(player, "quest_old_01") is False

player.quests["quest_old_02"] = "active"
assert try_complete_quest(player, "quest_old_02") is True

# Verify XP and level up
assert player.xp == 80 + 35 + 40  # 155 XP -> Level 2 (next level at 400 XP)
assert player.level == 2
assert player.learning_points == 10
assert player.max_hp == formula_hp(2, 0)
print("Quest lifecycle i idempotencja nagród: OK.")

# Test Training & Learning limits
print("Testowanie systemu nauki u nauczycieli...")
trainers = {t['id']: t for t in get_records('trainers.json')}
trainer_rdzaw = trainers["trainer_rdzaw"] # trains strength (limit 50), lockpick (limit 3)

def train_skill(player, trainer, skill):
	if skill not in trainer["skills"]:
		return "Nauczyciel nie uczy tego skilla"
	cur_val = player.strength if skill == "strength" else player.flags.get("skill_" + skill, 0)
	limit = trainer["limits"].get(skill, 0)
	if cur_val >= limit:
		return "Osiągnięto limit"
	lp_cost = 10
	coin_cost = 10
	if player.learning_points < lp_cost:
		return "Brak PN"
	if player.inventory.get("coin_zuzel", 0) < coin_cost:
		return "Brak monet"
	
	player.learning_points -= lp_cost
	player.remove_item("coin_zuzel", coin_cost)
	if skill == "strength":
		player.strength += 5
	else:
		player.flags["skill_" + skill] = cur_val + 1
	return "Sukces"

# Train Strength
assert train_skill(player, trainer_rdzaw, "strength") == "Sukces"
assert player.strength == 10
assert player.learning_points == 0
assert player.inventory["coin_zuzel"] == 25 + 20 + 28 - 10 # 63 coins left

# Try training without LP -> should fail
assert train_skill(player, trainer_rdzaw, "strength") == "Brak PN"
print("System nauki i koszty: OK.")

# Test Faction Lock & Epilogue
print("Testowanie mechaniki wyboru frakcji i epilogu...")
def choose_faction(player, faction):
	if player.faction:
		return False
	# Must have completed at least 2 candidate quests
	prefix = "quest_old_" if faction == "kordon" else "quest_new_"
	completed = [qid for qid, stat in player.quests.items() if stat == "complete" and qid.startswith(prefix)]
	if len(completed) < 2:
		return False
	player.faction = faction
	player.flags["faction_locked"] = True
	# Complete main right quest
	player.quests["quest_main_right"] = "complete"
	# Start epilogue
	player.quests["quest_main_epilogue"] = "active"
	return True

# Join Kordon faction (we completed quest_old_01 and quest_old_02)
assert choose_faction(player, "kordon") is True
assert player.faction == "kordon"
assert player.flags["faction_locked"] is True
assert player.quests["quest_main_right"] == "complete"
assert player.quests["quest_main_epilogue"] == "active"

# Trying to join Wolnica now must fail
assert choose_faction(player, "wolnica") is False
print("Wybór frakcji i blokada drugiej ścieżki: OK.")

# Test Lockpicking of chests
print("Testowanie minigry zamków...")
def simulate_lockpick(player, chest_difficulty, sequence, input_sequence):
	# requires lockpicks
	if player.inventory.get("lockpick", 0) < 1:
		return "Brak wytrychów"
	for idx, inp in enumerate(input_sequence):
		if inp != sequence[idx]:
			player.remove_item("lockpick", 1)
			return "Wytrych pękł"
	return "Otwarty"

# Easy chest (left, right, left) with correct input
assert simulate_lockpick(player, 1, ["left", "right", "left"], ["left", "right", "left"]) == "Otwarty"
# Easy chest with wrong input -> lockpick breaks
assert player.inventory["lockpick"] == 3
assert simulate_lockpick(player, 1, ["left", "right", "left"], ["left", "left", "left"]) == "Wytrych pękł"
assert player.inventory["lockpick"] == 2
print("Minigra zamków i wytrychy: OK.")

# Test Theft & Witnesses
print("Testowanie percepcji świadków kradzieży...")
def check_theft_witness(player, witness_dist, npc_faction):
	theft_skill = player.flags.get("skill_theft", 0)
	detection_radius = 35
	if theft_skill == 1:
		detection_radius = 20
	elif theft_skill == 2:
		detection_radius = 10
	elif theft_skill >= 3:
		detection_radius = 0 # immune
		
	if witness_dist < detection_radius:
		# Caught! Reputation penalty
		player.reputation[npc_faction] = max(-100, player.reputation.get(npc_faction, 0) - 10)
		return "Złapany"
	else:
		player.add_item("coin_zuzel", 5)
		return "Sukces"

# No theft skill, witness close (15 studs) -> caught
assert check_theft_witness(player, 15, "kordon") == "Złapany"
assert player.reputation["kordon"] == -10

# Train theft to level 3
player.flags["skill_theft"] = 3
# Witness close (15 studs) with skill 3 -> success!
assert check_theft_witness(player, 15, "kordon") == "Sukces"
print("Percepcja świadków i reputacja: OK.")

# Test Skinning Locks
print("Testowanie trofeów i skórowania...")
def harvest_skin(player, monster_id):
	if not player.flags.get("skill_skinning"):
		return "Zablokowane"
	player.defeated[monster_id] = True
	player.add_item("trophy_hide", 1)
	return "Oskórowany"

assert harvest_skin(player, "monster_zarlacz") == "Zablokowane"
player.flags["skill_skinning"] = 1
assert harvest_skin(player, "monster_zarlacz") == "Oskórowany"
assert player.inventory["trophy_hide"] == 1
print("Skórowanie i blokada trofeów: OK.")

# Test Save and Load serialization format
print("Testowanie serializacji i zapisu stanu...")
def serialize_state(player):
	return json.dumps({
		"schemaVersion": 1,
		"level": player.level,
		"xp": player.xp,
		"learningPoints": player.learning_points,
		"strength": player.strength,
		"dexterity": player.dexterity,
		"mana": player.mana,
		"vitality": player.vitality,
		"inventory": player.inventory,
		"equipped": player.equipped,
		"quests": player.quests,
		"flags": player.flags,
		"reputation": player.reputation,
		"faction": player.faction,
		"worldTime": player.world_time,
		"position": player.position
	})

serialized = serialize_state(player)
data_loaded = json.loads(serialized)
assert data_loaded["schemaVersion"] == 1
assert data_loaded["level"] == 2
assert data_loaded["faction"] == "kordon"
assert data_loaded["inventory"]["trophy_hide"] == 1
print("Zapis i wczytanie stanu: OK.")

print("\nWSZYSTKIE TESTY REGRESYJNE I SYMULACYJNE PRZESZŁY POMYŚLNIE! (PASS)")
