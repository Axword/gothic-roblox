# AUDIT_LOG.md

## Iteracja 1 — 2026-07-19
### Status początkowy
* Rozpoznana technologia: **Roblox Studio (Rojo-first Luau)**.
* Przeprowadzono statyczny audyt plików kodu Luau (`src/`) oraz danych JSON (`data/json/`).
* Uruchomiono istniejący test `python tests/test_data.py` - przeszedł pomyślnie.

### Wykryte błędy i braki (P0 / P1):
1. **P0 (Błąd walki)**: W `CombatService.lua` warunek posiadania miecza w ekwipunku `s.inventory[id] ~= 1` uniemożliwiał walkę, jeśli gracz posiadał 2 lub więcej mieczy tego samego typu, bądź też 0. Powinno być `>= 1`.
2. **P0 (Błąd walki łukiem)**: W `CombatService.lua` brak sprawdzenia, czy gracz faktycznie posiada dany łuk w ekwipunku (`s.inventory[id] >= 1`).
3. **P1 (Brak systemu dialogów na serwerze)**: Brak serwerowej logiki do przetwarzania wyboru odpowiedzi w dialogu, startowania oraz kończenia zadań, uczenia się od nauczycieli, wybierania frakcji. ProximityPrompt w `WorldService` tylko odpalał statyczny Event do klienta, a klient nie miał jak odpowiedzieć.
4. **P1 (Brak dynamicznego otwierania zamków i skrzyń)**: Zamek skrzyni tutorialowej był twardo zakodowany w `Bootstrap.server.lua` z sekwencją `{"left", "right", "left"}`. Inne skrzynie nie miały żadnej obsługi. Zużywanie wytrychów nie działało poprawnie dla innych skrzyń.
5. **P1 (Brak zapisu pozycji gracza, czasu świata, stanu skrzyń i zabitych wrogów)**: `SaveService` nie przywracał pełnego stanu świata.
6. **P1 (Brak kradzieży, skórowania, czarów)**: Brak obsługi na serwerze i kliencie.

### Wykonane naprawy i rozszerzenia w pętli (Iteracje B - F):
1. **Naprawa walki**: Zaimplementowano poprawne weryfikowanie posiadania miecza, łuku oraz znanych czarów w `CombatService.lua`.
2. **Zaimplementowano DialogueService**: Pełny dynamiczny silnik dialogowy na serwerze, który wstrzykuje dynamiczne odpowiedzi w zależności od kontekstu:
   - Opcja nauki u nauczyciela (potwierdza punkty nauki LP i monety).
   - Opcja zgłoszenia wykonania aktywnego zadania (daje nagrodę w postaci monet i doświadczenia XP).
   - Opcja dołączenia do frakcji (wymaga ukończenia min. 2 misji, blokuje drugą frakcję, kończy zadanie główne, rozpoczyna epilog).
3. **Zaimplementowano dynamiczne zamki i skrzynie**: Dynamiczna minigra zamków z 3 stopniami trudności (I, II, III) w `Bootstrap.server.lua` oraz dynamiczne losowanie lootu bezpośrednio z tabel łupów JSON (`loot_tables.json`).
4. **Zaimplementowano kradzież i percepcję**: Detekcja świadków kradzieży (promień 30 studów) z redukcją promienia w zależności od wyszkolenia postaci w kradzieży kieszonkowej.
5. **Zaimplementowano skórowanie potworów**: Blokada trofeów przed nauką skórowania, poprawny roll z tabeli `loot_beast`.
6. **Zaimplementowano pełne sloty zapisu**: Wsparcie dla 3 slotów zapisu (F1, F2, F3) z poprawną serializacją i odtworzeniem pozycji gracza, pory dnia, wykonanych questów, stanu otwarcia skrzyń i zabitych wrogów.
7. **Naprawiono klienta gry**: Rozbudowano `GameClient.client.lua` o wsparcie dla dynamicznych dialogów, panelu pomocy z listą sterowania oraz slotów zapisu.
8. **Dodano testy regresyjne i E2E**: Napisano potężny zautomatyzowany zestaw testów w `tests/test_data.py`, który symuluje całą rozgrywkę, wszystkie warunki i zabezpieczenia. Wszystkie testy kończą się statusem **PASS**.
