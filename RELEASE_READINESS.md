# RELEASE_READINESS.md

## Ocena gotowości wydania (2026-07-19)

* **Status ogólny**: `CONDITIONALLY READY` / `BLOCKED — STATIC AUDIT ONLY`
  (Projekt działa stabilnie w środowisku headless, lecz wymaga uruchomienia w Roblox Studio do pełnej weryfikacji grafiki i interfejsu użytkownika).

* **Kluczowe kryteria wyjścia**:
  - [x] Wszystkie dane JSON zweryfikowane pod kątem spójności referencji.
  - [x] Brak krytycznych błędów uniemożliwiających kompilację lub uruchomienie skryptów.
  - [ ] Wszystkie mechaniki walki, magii, otwierania zamków i kradzieży w pełni zintegrowane i przetestowane serwerowo.
  - [ ] Pełny cykl fabularny (wybór frakcji, blokada drugiej, epilog) grywalny na serwerze.

* **Zidentyfikowane ryzyka**:
  - Brak fizycznego interfejsu graficznego uniemożliwia bezpośredni test gry przez gracza bez uruchomienia Roblox Studio. Testowanie opiera się na symulacji zdarzeń sieciowych i logice serwera.
