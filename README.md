# Pogranicze Popiołu

Oryginalny, polskojęzyczny action-RPG vertical slice dla Roblox Studio: dwa porządki walczą o dolinę nad Gardzielą Próżni. Projekt jest **Rojo-first**; dane kanoniczne są w JSON, a `tools/build_data` tworzy moduły, które Roblox może załadować.

## Uruchomienie
1. Zainstaluj Rojo 7 i Roblox Studio; uruchom `./tools/build_data` oraz `rojo serve default.project.json`.
2. Otwórz Studio i połącz przez Rojo. W `Workspace` włącz `StreamingEnabled` (ustawienie publikacji, nie plik źródłowy).
3. Włącz Play. DataStore w Studio wymaga API Services; bez niego startuje bezpieczny stan domyślny.

`python tests/test_data.py` sprawdza JSON, referencje, minima zawartości i wzór HP. Do testu opublikowanego wymagane są osobne playtesty Studio — status w `PROGRESS.md`.

## Sterowanie wycinka
`E` interakcja z Promptem, `A/D` odpowiedź zamka, `Esc` opuszcza dialog, `F5` zapisuje. HUD i komunikaty są responsywne. System wejścia używa ContextActionService, dlatego łatwo przypisać przyciski dotykowe.

## Licencja / assety
Cała aktualna geometria jest proceduralna z prymitywów Roblox. Nie zaimportowano obcych assetów; szczegóły w `THIRD_PARTY_ASSETS.md`.
