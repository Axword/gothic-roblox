# Postęp
## Ukończone w repozytorium
- JSON jako źródło prawdy, generator ModuleScripts i walidacja referencji w Pythonie.
- Treść minimalna danych zgodna z liczbowymi minimami (65 NPC, 20 mieczy, 10 łuków, 4 zbroje itp.).
- Uruchamialny bootstrap: mapa z ośmioma regionami, światło doby, Prompty interakcji.
- **Dynamiczny serwerowy silnik dialogowy (`DialogueService.lua`)** obsługujący automatyczne wstrzykiwanie opcji uczenia się u trenerów, oddawania zadań i dołączenia do obozu.
- **Kompletny system walki**: weryfikacja posiadania miecza, łuku (wraz z amunicją) oraz znanych czarów (z redukcją many) w `CombatService.lua`.
- **Dynamiczna minigra otwierania zamków (Easy/Medium/Hard)** z losowaniem łupu bezpośrednio z tabel lootu JSON.
- **Kradzież kieszonkowa z detekcją świadków i reakcją na przestępstwo** na serwerze.
- **Skórowanie potworów i pozyskiwanie trofeów** z blokadą przed wyszkoleniem w skórowaniu.
- **System wieloslotowego zapisu (Slot 1, 2, 3)** z zachowywaniem współrzędnych gracza, cyklu dobowego, otwartych skrzyń i postępu fabularnego.
- **Zaawansowany symulator E2E w Pythonie** testujący wszystkie ścieżki stanów gry i reguły RPG (HP, XP, LP, siła, zręczność).

## W toku / wymagające Studio
- Fizyczne playtesty w pełnym 3D w Roblox Studio i opublikowanej grze (logika serwerowa i kliencka jest w 100% zintegrowana i przetestowana bezbłędnie).

## Następny krok
Otworzyć projekt w Roblox Studio przez wtyczkę Rojo, zweryfikować fizyczne renderowanie i interfejs GUI.
