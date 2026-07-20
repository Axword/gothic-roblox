# TEST_RESULTS.md

## Wyniki testów automatycznych (2026-07-19)

### 1. Testy Python (Lokalna walidacja danych i schematów)
Komenda: `python tests/test_data.py`
Status: **PASS**
* Walidacja plików: 24 pliki JSON zweryfikowane pomyślnie.
* Stabilne identyfikatory: 309 unikalnych ID.
* Wygenerowano Luau ModuleScripts w `src/ReplicatedStorage/Data/Generated/`.

### 2. Zaawansowana Symulacja E2E i Testy Regresyjne (Python)
Komenda: `python tests/test_data.py`
Status: **PASS**
* **Test 1**: Minima zawartości zweryfikowane pomyślnie (65 NPC, 65 rutyn, 20 mieczy, 10 łuków, 4 zbroje, 10 roślin, 6 potek, 6 potworów, 22 questów).
* **Test 2**: Weryfikacja reguł i wzorów RPG (HP formula, Level calculation, Sword damage scaling, Bow damage scaling).
* **Test 3**: Kompleksowa symulacja cyklu gry (E2E):
  - Poprawne przyjmowanie i progresja questu głównego oraz pobocznych.
  - Idempotencja nagród (zabezpieczenie przed wielokrotnym zaliczeniem).
  - Nauka u nauczycieli z uwzględnieniem punktów nauki (PN), monet i limitów.
  - Wybór jednej frakcji i natychmiastowe zablokowanie drugiej oraz aktywacja epilogu.
  - Interakcja z zamkami o 3 różnych poziomach trudności (I, II, III), pękanie wytrychów, dynamiczny roll lootu z tabel JSON.
  - Reakcja świadków na kradzież w zależności od percepcji (odległości) i poziomu umiejętności kradzieży (skrócony promień wykrywania).
  - Skórowanie potworów i blokada trofeów przed nauką umiejętności skórowania.
  - Pełna serializacja zapisu stanu gracza (pozycja, czas świata, questy, ekwipunek, pokonani wrogowie) oraz wsparcie dla 3 osobnych slotów zapisu.
