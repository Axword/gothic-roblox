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
