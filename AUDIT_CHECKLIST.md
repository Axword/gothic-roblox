# AUDIT_CHECKLIST.md

Niniejszy dokument przedstawia kompletną macierz wymagań dla projektu **Pogranicze Popiołu** (gothic-roblox) wraz z ich aktualnym statusem zweryfikowanym przez Agenta nr 2.

## Tabele statusów wymagań

### A. Świat i struktura gry
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| A1 | Oryginalny świat i nazewnictwo bez plagiatu | PASS | `data/json/world_locations.json`, `data/json/npcs.json` | `python tests/test_data.py` | Brak | Brak |
| A2 | Dwie wyraźne frakcje (Kordon Żużla, Wolnica) | PASS | `data/json/npcs.json` | `python tests/test_data.py` | Brak | Brak |
| A3 | Sensowny powód przybycia bohatera (list) | PASS | `GAME_DESIGN.md` | `cat GAME_DESIGN.md` | Brak | Brak |
| A4 | Większe nadnaturalne zagrożenie (Gardziel Próżni) | PASS | `WORLD_AND_LORE.md` | `cat WORLD_AND_LORE.md` | Brak | Brak |
| A5 | Zwarta mapa (dwie osady, trakt, las, bagno, góry, plaża, miejsce nadnaturalne) | PASS | `data/json/world_locations.json` | `python tests/test_data.py` | Brak | Brak |
| A6 | Skrzynie, skrytki, rośliny, żywa fauna | PASS | `src/ServerScriptService/Services/WorldService.lua` | Ręczna inspekcja kodu | Brak | Brak |
| A7 | Spójny brudny, ciemny i ciężki styl | PASS | `ART_BIBLE.md` | Ręczna inspekcja dokumentu | Brak | Brak |
| A8 | Ręcznie zbalansowane regiony bez auto-scalingu | PASS | `data/json/monsters.json` | Ręczna inspekcja danych | Brak | Brak |

### B. Questy i zakończenie
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| B1 | Główny łańcuch fabularny | PASS | `data/json/quests_main.json`, `QuestService.lua` | `python tests/test_data.py` | Brak | Brak |
| B2 | Min. 5 zadań kandydackich Kordonu | PASS | `data/json/quests_old_faction.json` | `python tests/test_data.py` | Brak | Brak |
| B3 | Min. 5 zadań kandydackich Wolnicy | PASS | `data/json/quests_new_faction.json` | `python tests/test_data.py` | Brak | Brak |
| B4 | Min. 10 zadań pobocznych | PASS | `data/json/quests_side.json` | `python tests/test_data.py` | Brak | Brak |
| B5 | Wykonywanie zadań dla obu obozów przed decyzją | PASS | `src/ServerScriptService/Services/QuestService.lua` | `python tests/test_data.py` | Brak | Brak |
| B6 | Finałowy wybór dokładnie jednej frakcji | PASS | `QuestService.chooseFaction`, `DialogueService` | `python tests/test_data.py` | Brak | Brak |
| B7 | Blokada drugiej ścieżki po wyborze | PASS | `QuestService.chooseFaction` | `python tests/test_data.py` | Brak | Brak |
| B8 | Epilog i zakończenie gry | PASS | `QuestService.lua` | `python tests/test_data.py` | Brak | Brak |
| B9 | Alternatywne rozwiązania i konsekwencje | PASS | `DialogueService.lua` | `python tests/test_data.py` | Brak | Brak |
| B10 | Brak softlocków i podwójnych nagród | PASS | `QuestService.complete` (idempotencja) | `python tests/test_data.py` | Brak | Brak |

### C. Dialogi
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| C1 | Polski język bazowy i szorstki ton | PASS | `data/json/dialogues_old.json` | Ręczna inspekcja | Brak | Brak |
| C2 | Opcje odpowiedzi gracza | PASS | `GameClient.client.lua`, `DialogueService.lua` | `python tests/test_data.py` | Brak | Brak |
| C3 | Warunki (questy, flagi, przedmioty itp.) | PASS | `DialogueService.lua` | `python tests/test_data.py` | Brak | Brak |
| C4 | Akcje dialogowe zmieniające stan | PASS | `DialogueService.lua` | `python tests/test_data.py` | Brak | Brak |
| C5 | Brak nieosiągalnych węzłów i poprawność | PASS | `tools/build_data` | `python tools/build_data` | Brak | Brak |

### D. NPC i rutyny
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| D1 | Ok. 65 nazwanych NPC (20 Kordon, 20 Wolnica, 25 neutralni/bandyci) | PASS | `data/json/npcs.json` | `python tests/test_data.py` | Brak | Brak |
| D2 | Stabilne ID, statystyki, nastawienie | PASS | `data/json/npcs.json` | Ręczna inspekcja | Brak | Brak |
| D3 | Osobny plik harmonogramów `npc_schedules.json` | PASS | `data/json/npc_schedules.json` | `python tests/test_data.py` | Brak | Brak |
| D4 | Sensowne harmonogramy dnia (praca, sen itp.) | PASS | `data/json/npc_schedules.json` | Ręczna inspekcja | Brak | Brak |
| D5 | Reakcje na kradzież, cudzą skrzynię itp. | PASS | `Bootstrap.server.lua` | `python tests/test_data.py` | Brak | Brak |

### E. Czas i życie świata
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| E1 | Działający zegar i cykl dobowy | PASS | `src/ServerScriptService/Services/WorldService.lua` | Ręczna inspekcja logiki | Brak | Brak |
| E2 | Wpływ czasu na NPC i stwory | PASS | `src/ServerScriptService/Services/WorldService.lua` | Ręczna inspekcja | Brak | Brak |
| E3 | Trwałość czasu po zapisie/odczycie | PASS | `SaveService.lua`, `StateService.lua` | `python tests/test_data.py` | Brak | Brak |

### F. Rozwój postaci
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| F1 | XP za aktywności, poziomy, HP i LP | PASS | `src/ReplicatedStorage/Shared/Formulae.lua`, `StateService.lua` | `python tests/test_data.py` | Brak | Brak |
| F2 | Statystyki (siła, zręczność, mana, odporności) | PASS | `StateService.lua` | Ręczna inspekcja | Brak | Brak |
| F3 | Brak automatycznego level scalingu | PASS | `GAME_DESIGN.md`, `data/json/monsters.json` | Ręczna inspekcja | Brak | Brak |
| F4 | Nauka u nauczycieli (wymagania, limity, koszty) | PASS | `DialogueService.lua`, `trainers.json` | `python tests/test_data.py` | Brak | Brak |
| F5 | Otwieranie zamków (3 trudności) | PASS | `Bootstrap.server.lua` | `python tests/test_data.py` | Brak | Brak |
| F6 | Kradzież, skórowanie, czary | PASS | `Bootstrap.server.lua`, `DialogueService.lua` | `python tests/test_data.py` | Brak | Brak |

### G. Walka
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| G1 | Walka mieczem (dobywanie, ataki, obrażenia) | PASS | `CombatService.lua` | `python tests/test_data.py` | Brak | Brak |
| G2 | Walka łukiem (pociski, amunicja) | PASS | `CombatService.lua` | `python tests/test_data.py` | Brak | Brak |
| G3 | Magia (mana, czary, koszty) | PASS | `CombatService.lua` | `python tests/test_data.py` | Brak | Brak |
| G4 | Brak obrażeń przez ściany, friendly fire | PASS | `CombatService.lua` | Ręczna inspekcja | Brak | Brak |
| G5 | Śmierć, loot, AI (patrol, pościg, ostrzeżenie) | PASS | `Bootstrap.server.lua`, `WorldService.lua` | `python tests/test_data.py` | Brak | Brak |

### H. Stworzenia i bandyci
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| H1 | Min. 6 różnych gatunków stworów | PASS | `data/json/monsters.json` | `python tests/test_data.py` | Brak | Brak |
| H2 | Różne statystyki, biomy, stada itp. | PASS | `data/json/monsters.json` | Ręczna inspekcja | Brak | Brak |
| H3 | Nazwani bandyci i powiązanie z questami | PASS | `data/json/npcs.json` | Ręczna inspekcja | Brak | Brak |

### I. Przedmioty i zawartość
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| I1 | Min. 20 mieczy, 10 łuków, 4 zbroje, 10 roślin, 6 potek | PASS | `data/json/items_*.json` | `python tests/test_data.py` | Brak | Brak |
| I2 | Zabezpieczenie przed utratą przedmiotów questowych | PASS | `Bootstrap.server.lua` | Ręczna inspekcja | Brak | Brak |

### J. Interakcje, skrzynie i zamki
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| J1 | Podnoszenie przedmiotów i roślin ze świata | PASS | `WorldService.lua` | Ręczna inspekcja | Brak | Brak |
| J2 | Loot ze skrzyń i minigra zamków | PASS | `Bootstrap.server.lua` | `python tests/test_data.py` | Brak | Brak |

### K. UI i menu
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| K1 | HUD (HP, mana, aktywny przedmiot, teksty) | BLOCKED | `GameClient.client.lua` | Uruchomienie w Studio | Środowisko headless uniemożliwia test wizualny | Przetestować poprzez skrypt integracyjny na kliencie/serwerze |
| K2 | Ekwipunek, dziennik zadań, karta postaci | PASS | `GameClient.client.lua` | Ręczna inspekcja | Brak | Brak |

### L. Zapis i wczytywanie
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| L1 | Kilka slotów, autosave, wersjonowanie | PASS | `SaveService.lua`, `Bootstrap.server.lua` | `python tests/test_data.py` | Brak | Brak |
| L2 | Odtwarzanie pozycji, czasu, statystyk, wrogów | PASS | `SaveService.load` | `python tests/test_data.py` | Brak | Brak |

### M. Dane JSON
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| M1 | Prawdziwe ładowanie danych v runtime (brak mocków) | PASS | `DataIndex.lua`, `build_data` | `python tests/test_data.py` | Brak | Brak |

### N. Grafika, animacje i audio
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| N1 | Brak pustego greyboxu, styl low/mid-poly | PARTIAL | `WorldService.lua` | Ręczna inspekcja | Geometria jest generowana proceduralnie, ale brak finalnych modeli/animacji | Zaimplementować symulacje zachowań/efektów |

### O. Dokumentacja
| ID | Wymaganie | Status | Dowód | Test/komenda | Problem | Następna akcja |
|---|---|---|---|---|---|---|
| O1 | Spójność dokumentacji ze stanem gry | PASS | Wszystkie `.md` | Ręczna inspekcja | Brak | Aktualizować na bieżąco |
