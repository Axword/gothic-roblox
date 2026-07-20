# BUGS.md

## Aktywne błędy (stan na początku audytu) — BRAK AKTYWNYCH BŁĘDÓW!

## Zamknięte błędy

### BUG-01: Błąd sprawdzania broni w CombatService [P0]
* **Opis**: Warunek `s.inventory[id] ~= 1` w `CombatService.lua` uniemożliwiał walkę mieczem, jeśli gracz miał więcej niż jeden miecz tego samego typu w ekwipunku.
* **Rozwiązanie**: Warunek został zmieniony na `(s.inventory[id] or 0) < 1` co pozwala na walkę gdy gracz posiada co najmniej 1 miecz.
* **Status**: ZAMKNIĘTY.

### BUG-02: Brak sprawdzenia posiadania łuku w CombatService [P0]
* **Opis**: Przy walce łukiem sprawdzana była obecność amunicji oraz poprawność id broni, ale nie była sprawdzana obecność samego łuku w ekwipunku.
* **Rozwiązanie**: Dodano warunek `(s.inventory[id] or 0) < 1`.
* **Status**: ZAMKNIĘTY.

### BUG-03: Brak weryfikacji znajomości czaru [P1]
* **Opis**: `Combat.damageTarget` pozwalał na użycie dowolnego czaru, o ile gracz miał wystarczającą ilość many, nawet jeśli go nie poznał.
* **Rozwiązanie**: Dodano warunek `(not s.inventory[id] and not s.flags["learned_spell_"..id])` w `CombatService.lua`.
* **Status**: ZAMKNIĘTY.

### BUG-04: Brak idempotencji nagród za questy [P1]
* **Opis**: Brak sprawdzania, czy quest nie został już ukończony, co umożliwiało wielokrotne przyznawanie nagród przy błędnym wywołaniu.
* **Rozwiązanie**: Wzmocniono sprawdzanie w `QuestService.complete` (metoda uniemożliwia wielokrotne przyznawanie nagród dla nieaktywnego lub już ukończonego zadania).
* **Status**: ZAMKNIĘTY.
