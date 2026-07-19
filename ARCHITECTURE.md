# Architektura
`data/json` → `tools/build_data` → `ReplicatedStorage/Data/Generated`; klient nigdy nie czyta plików. `DataIndex` ładuje tylko wygenerowane ModuleScripty.

Serwer: `StateService` (stan), `QuestService` (etapy/finał), `CombatService` (dystans, koszt many/amunicji, obrażenia), `WorldService` (proceduralna mapa/doba/Prompty), `SaveService` (DataStore `UpdateAsync`). `Bootstrap.server.lua` tworzy remotes i ogranicza akcje do 12/s. Serwer sprawdza typ, dystans, ekwipunek oraz stan zamka; klient tylko wyświetla UI i wysyła zamiar.

Save ma `schemaVersion`, ID zamiast Instance, domyślne wartości oraz bezpieczne odrzucanie nieznanej wersji. Przestępstwa, AI grupowe, pełny UI i eksport Studio pozostają P0/P1 — nie są deklarowane jako ukończone.

`TrainerService` zatwierdza naukę wyłącznie przy rzeczywistym NPC; `CrimeService` używa zasięgu i raycastu świadka; `CombatService` sprawdza śmierć bestii oraz rangę skórowania. Zamki odnoszą się do `world_interactables` po stabilnym ID i nie wydają łupu drugi raz.

`DialogueService` przechowuje sesję węzła per gracz. `dialogueChoice` przyjmuje wyłącznie indeks 1–8 aktualnej serwerowej odpowiedzi; akcje JSON są interpretowane na serwerze. To eliminuje możliwość wysłania przez klienta dowolnego ID questa lub frakcji.
