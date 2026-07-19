# Postęp
## Ukończone w repozytorium
- JSON jako źródło prawdy, generator ModuleScripts i walidacja referencji.
- Treść minimalna danych zgodna z liczbowymi minimami.
- Uruchamialny bootstrap: mapa z ośmioma regionami, światło doby, Prompt, dialog startowy, zamek sekwencyjny, NPC/monster model i DataStore.

## W toku / wymagające Studio
- Smoke test w opublikowanym doświadczeniu nie został wykonany; zatem żadna funkcja nie jest reklamowana jako potwierdzona w publikacji.
- Rozbudowa pionowego prototypu do wszystkich NPC, UI i systemów P0.

## Następny krok
Uruchomić Rojo w Studio, wykonać test PLAY opisany w `TEST_PLAN.md`, a następnie wdrożyć prawdziwe AI/NPC schedules i ekrany ekwipunku/questów.

## Iteracja 2
- Wszystkie nazwane NPC są teraz spawnowane jako proceduralne reprezentacje runtime i odczytują marker aktywności z `npc_schedules.json`.
- Minimalny klient ma panele I/J/C i wybór stylu 1/2/3 z atakiem F. To nadal prototyp UI, nie finalny interfejs.

## Iteracja 3
- Wycinek ma funkcjonalny obiekt cudzej własności i lokalne reakcje świadków (ostrzeżenie/alarm zależny od liczby świadków). Pełna eskalacja grzywny, walki i zwrotu pozostaje P0.

## Iteracja 4
- Nauczyciele, rangi zamków I–III i pozyskiwanie trofeów mają ścieżkę wykonania w runtime. UI treningu jest celowo skromne: T kupuje pierwszą umiejętność z listy aktualnego nauczyciela; wybór konkretnej umiejętności jest P1.

## Iteracja 5
- Dialogi nie są już wyłącznie etykietą: serwer przechowuje aktywny węzeł i wykonuje akcje `startQuest`, `completeQuest`, `chooseFaction` oraz `learnSpell`. Obecne dialogi liderów świadomie skracają etapowe cele do raportu, aby umożliwić test pełnego przepływu; docelowe cele terenowe pozostają P0.

## Iteracja 6
- Wszystkie 10 kandydackich questów ma możliwy do wykonania, serwerowo rejestrowany cel terenowy. Dwa pierwsze każdej frakcji są podłączone do dialogu lidera i pełnego wyboru frakcji; pozostałe cele są przygotowane w danych/world markerach, a ich przyjęcie zostanie połączone z odpowiednimi zleceniodawcami.

## Iteracja 7
- Każdy z sześciu gatunków potworów ma runtime spawn z `monster_spawns.json`; zachowanie jest nadal lekką, proceduralną AI (bez PathfindingService i animacji). Flora jest zbieralna i zapisuje ID przedmiotu do ekwipunku.

## Iteracja 8
- Wszystkie deklarowane questy są teraz możliwe do przyjęcia przez dialog i raportowania; questy kandydackie wymagają dodatkowo własnego celu terenowego. Menu pauzy działa jako nakładka z Zapisz/Wczytaj; osobne menu startowe, sloty i pełne opcje sprzętowe nadal są P1/P0.

## Iteracja 9
- Zapis ma trzy sloty (`p_<UserId>_slot_1..3`) i bezpiecznie ogranicza wybrany indeks. Środowisko otrzymało proceduralny dressing oraz mgłę cząsteczkową. Ustawienia są wciąż lokalne dla sesji, a nie serializowane.

## Audyt dokumentacji — 2026-07-19
- Zsynchronizowano opis sterowania, slotów i stanu magii z aktualnym kodem.
- Dokumenty rozróżniają dane/prototypy obecne w repozytorium od funkcji potwierdzonych playtestem Studio.
- Najważniejsza pozostała luka dokumentacyjna nie jest ukryta: brak opublikowanego testu oraz brak finalnego AI, animacji i UI produkcyjnego.

## Rejestr domknięcia
Pełny, utrzymywany rejestr braków oraz kolejność prac znajduje się w `IMPLEMENTATION_GAPS.md`. Jest źródłem prawdy dla elementów, których nie należy błędnie oznaczać jako ukończone.

## Iteracja 13
- Rutyny NPC korzystają z `PathfindingService` i fallbacku widoczności. Nadal są to proceduralne proxy bez rigów R15, dlatego finalne animacje pracy/snu pozostają P0.
