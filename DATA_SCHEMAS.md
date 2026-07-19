# Dane i ID
Każdy rekord ma unikalne małe ID `snake_case`; `record.schema.json` wymaga ID, a generator odrzuca duplikaty, zły format i brak referencji w polach `*Id`/`requires*`.

Kategorie `items_*`, `npcs`, `npc_schedules`, `monsters`, `monster_spawns`, `quests_*`, `dialogues_*`, `world_locations`, `loot_tables`, `trainers`, `spells`, `balance` są wersjonowane (`schemaVersion: 1`). `savegame.json` jest wyłącznie dokumentacją serializacji i nie jest runtime source.
