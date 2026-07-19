# Wyzwania i decyzje
- Roblox nie czyta dowolnych plików po publikacji: JSON kompiluje się do ModuleScripts; nie ma runtime File I/O.
- Mapa i grafika są celowo proceduralne, aby nie łamać licencji ani nie udawać gotowych meshów. Specyfikacje visual są w danych.
- DataStore może być wyłączony w Studio: `pcall` pozostawia domyślny stan zamiast blokować grę.
- Pełny zakres jest większy niż bezpieczna pierwsza iteracja. Priorytetem był działający, mały przepływ i ścieżka skalowania, nie puste deklaracje.
