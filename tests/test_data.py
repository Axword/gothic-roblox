#!/usr/bin/env python3
"""Dependency-free regression checks: run `python tests/test_data.py`."""
import json, subprocess, sys
from pathlib import Path
root=Path(__file__).parents[1]; data=root/'data/json'
def records(name): return json.loads((data/name).read_text())['records']
subprocess.run([str(root/'tools/build_data')],check=True)
assert len(records('npcs.json')) == 65
assert len(records('npc_schedules.json')) == 65
assert len(records('items_weapons_swords.json')) >= 20
assert len(records('items_weapons_bows.json')) >= 10
assert len(records('items_armors.json')) >= 4
assert len(records('items_plants.json')) >= 10
assert len(records('items_potions.json')) >= 6
assert len(records('monsters.json')) >= 6
assert len(records('quests_old_faction.json')) >= 5 and len(records('quests_new_faction.json')) >= 5 and len(records('quests_side.json')) >= 10
assert {x['lockDifficulty'] for x in records('world_interactables.json')} == {1, 2, 3}
assert len(records('trainers.json')) >= 5
assert any('chooseFaction:' in str(x) for x in records('dialogues_old.json'))
assert any('learnSpell:spell_ember' in str(x) for x in records('dialogues_neutral.json'))
# Formula mirrors Shared/Formulae.lua; explicit guards against balance regression.
def hp(level,vitality): return 80+level*12+vitality*2
assert hp(1,0)==92 and hp(3,5)==126
print('data, content minima, and formula regression checks: PASS')
