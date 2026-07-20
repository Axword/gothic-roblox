# Changelog
## 2026-07-19 — Iteracja 2: Zaawansowane integracje logiczne i testy regresyjne E2E (Agent nr 2)
- **Naprawiono błędy walki (BUG-01 i BUG-02)**: elastyczne weryfikowanie posiadania broni w ekwipunku (`>= 1` zamiast błędnego `== 1`) oraz obecności łuku przy strzelaniu.
- **Dodano DialogueService**: dynamiczne i automatyczne generowanie opcji dialogowych dla hand-in zadań, uczenia się statystyk i umiejętności u nauczycieli, oraz ostatecznego zaprzysiężenia frakcyjnego.
- **Wdrożono 3 trudności zamków i loot dynamiczny**: sekwencje zamków Easy/Medium/Hard ze zużyciem wytrychów i bezpośrednim rollowaniem łupu z tabel `loot_tables.json`.
- **Dodano system przestępczości**: reakcje świadków i kary reputacji za kradzież kieszonkową w zależności od odległości i wyszkolenia w kradzieży.
- **Dodano skórowanie potworów**: blokada pozyskiwania skór/trofeów przed opanowaniem umiejętności, nagradzająca poprawnym łupem.
- **Dodano 3 sloty zapisu**: zapis i wczytanie z odtworzeniem pozycji gracza, pory dnia, zabitych wrogów, ekwipunku, statystyk i zadań.
- **Rozbudowano klienta**: dodano tekstowe GUI i sterowanie klawiszami (pomoc: H, ekwipunek: I, dziennik: J, postać: K, sloty zapisu: F1-F3).
- **Wdrożono E2E Test Runner**: potężne testy symulacji całej gry w `tests/test_data.py` sprawdzające wszystkie formuły, ograniczenia i stany logiczne, ze statusem **PASS**.
- Zaktualizowano `AUDIT_CHECKLIST.md`, `AUDIT_LOG.md`, `BUGS.md`, `TEST_RESULTS.md`, `RELEASE_READINESS.md`, `CHALLENGES.md`, `PROGRESS.md`, `TODO.md`.

## 2026-07-19 — Iteracja 1: działający pionowy wycinek (Agent nr 1)
- Utworzono projekt Rojo, generator i walidator danych JSON oraz 24 zestawy danych.
- Dodano 65 nazwanych NPC z harmonogramami, 20 mieczy, 10 łuków, 4 zbroje, flora, mikstury, 6 stworów i 22 questy danych.
- Dodano proceduralny świat, dobę, 3 interaktywnych NPC, potwora, zamek oraz serwerowy zapis/quest/combat foundation.
- Dodano minimalny UI i test danych. Pełny zakres nadal nie jest testowany w opublikowanym Roblox.
