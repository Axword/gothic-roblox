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
- Startowy ekwipunek wycinka obejmuje miecz, łuk i strzały; Żarzący Grot jest nauczany później w queście Karpa, aby magia miała uzasadnienie fabularne.
- Dodano serwerowy test własności łupu z promieniem i raycastem świadka; reputacja spada tylko gdy NPC realnie może zobaczyć czyn.

## 2026-07-19 — Iteracja 4: nauka, zamki i pozyskiwanie
- Dodano serwerowo autorytatywne szkolenie u pięciu nauczycieli: koszt PN/żużlu, limit, dystans i zakres z JSON.
- Dodano trzy skrzynie o poziomach zamka I–III, sekwencje oraz łup definiowane wyłącznie w danych.
- Dodano serwerowo walidowane skórowanie pokonanej bestii po nauce u Żaby.

## 2026-07-19 — Iteracja 5: autorytatywne dialogi i droga do finału
- Dodano serwerowy `DialogueService`: klient wybiera numer odpowiedzi, ale węzły, akcje questów i wybór frakcji zatwierdza serwer.
- Borzuj i Runa prowadzą działający skrócony łańcuch kandydacki do dwóch zadań i wyboru frakcji; epilog jest zależny od strony.
- Pustelnik Karp oferuje zadanie i dopiero po jego ukończeniu uczy Żarzącego Grotu.

## 2026-07-19 — Iteracja 6: cele terenowe questów
- Pięć zadań kandydackich każdej frakcji ma teraz dane celu, typu i postępu zamiast samych opisów.
- `QuestService` zapisuje postęp po stabilnym ID, blokuje raport przed realizacją celu i rozpoznaje stan `ready`.
- Do świata dodano dziesięć obiektów dowodów/zleceń; pierwszy cel Wolnicy realizuje się przez pokonanie Żarłacza.

## 2026-07-19 — Iteracja 7: fauna i zbieractwo w runtime
- Wszystkie sześć gatunków stworów oraz ich spawny z JSON są reprezentowane na mapie, z osobnymi sylwetkami i podstawowymi zachowaniami pack/tank/ranged/nocturnal/ambush/caster.
- Cele walki używają unikalnego `SpawnId`, więc obrażenia i skórowanie nie mieszają wielu osobników tego samego gatunku.
- Wszystkie dziesięć gatunków roślin otrzymało zbieralne reprezentacje świata.

## 2026-07-19 — Iteracja 8: kompletne podłączenie zleceń i pauza
- Wszystkie pięć kandydackich questów każdej frakcji otrzymało zleceniodawcę dialogowego; dziesięć zadań pobocznych ma własne punkty przyjęcia/raportu.
- Dodano minimalistyczne menu pauzy z zapisem/wczytaniem oraz lokalnymi ustawieniami prezentacji.

## 2026-07-19 — Iteracja 9: sloty zapisu i dressing środowiska
- DataStore obsługuje trzy walidowane sloty per gracz; pauza udostępnia sloty 1–3.
- Dodano proceduralne drzewa, skały kamieniołomu, wybrzeże i mgłę bagienną, bez zewnętrznych assetów.
- Dodano lokalne przełączanie czułości myszy i napisów pod O.

## 2026-07-19 — Iteracja 10: aktywny ekwipunek
- Dodano serwerowy `InventoryService`: wybór/wyposażanie broni i pancerza, używanie mikstur oraz roślin, blokadę przedmiotów questowych.
- Klient obsługuje cykl Z i aktywację X; serwer sprawdza posiadanie przedmiotu przed zmianą stanu.

## 2026-07-19 — Iteracja 11: combat stance i eskalacja alarmu
- Dodano serwerowe lekkie/mocne ciosy, trzyetapowy combo liczony czasowo, staminę, blok i unik.
- Klient wykonuje proceduralne pozy Motor6D dla R15 przy ciosie/bloku/uniku; finalne assety Animation Editor pozostają P1.
- Alarm po przestępstwie oznacza gracza per frakcja, a pobliscy NPC frakcji zadają obrażenia.
