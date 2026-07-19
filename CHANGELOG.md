# Changelog
## 2026-07-19 — Iteracja 1: działający pionowy wycinek
- Utworzono projekt Rojo, generator i walidator danych JSON oraz 24 zestawy danych.
- Dodano 65 nazwanych NPC z harmonogramami, 20 mieczy, 10 łuków, 4 zbroje, flora, mikstury, 6 stworów i 22 questy danych.
- Dodano proceduralny świat, dobę, 3 interaktywnych NPC, potwora, zamek oraz serwerowy zapis/quest/combat foundation.
- Dodano minimalny UI i test danych. Pełny zakres nadal nie jest testowany w opublikowanym Roblox.

## 2026-07-19 — Iteracja 2: gęstość świata i runtime UI
- Wszystkie 65 rekordów NPC jest teraz reprezentowane na proceduralnej mapie i otrzymuje aktywność/marker z harmonogramu.
- Dodano markery pracy, jedzenia, ogniska, snu i bezpieczne fallbacki frakcji oraz serwerowy ruch rutynowy.
- Dodano prostą agresję Żarłacza trzcin i klawiszowe wybieranie/ataki mieczem, łukiem lub czarem.
- Dodano panele ekwipunku, dziennika i postaci z synchronizacją snapshotu serwera.

## 2026-07-19 — Iteracja 3: walka i świadkowie
- Startowy ekwipunek wycinka obejmuje miecz, łuk, strzały i jeden uczony czar, dzięki czemu można testować trzy style.
- Dodano serwerowy test własności łupu z promieniem i raycastem świadka; reputacja spada tylko gdy NPC realnie może zobaczyć czyn.
