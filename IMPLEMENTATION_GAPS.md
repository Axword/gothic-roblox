# Braki implementacyjne i plan domknięcia

> Audyt: 2026-07-19. Ten plik jest świadomym rejestrem różnicy między **danymi/prototypem w repozytorium** a funkcją potwierdzoną testem Roblox Studio. Nie wolno odznaczać punktu bez testu z `TEST_PLAN.md`.

## P0 — blokery deklaracji „kompletna gra”

| Obszar | Jest w repozytorium | Brak do spełnienia projektu | Pliki startowe | Kryterium zamknięcia |
|---|---|---|---|---|
| Playtest | Test generatora JSON przechodzi | Test Studio i opublikowany private server | `TEST_PLAN.md` | Pełny smoke flow zapisany jako PASS z datą i buildem |
| R15 / animacje | Proceduralne pozy `Motor6D` dla ataku, bloku, uniku | Rigi R15, Animator, idle/walk/run/atak/łuk/cast/hit/death, animacje potworów | `GameClient.client.lua`, nowe `AnimationService.lua` | Każda akcja gra własną animację i nie walczy z domyślnym Animate |
| Walka | Serwer waliduje zasięg, combo, stamina, blok, unik, łuk/magia | Hurtboxy, pociski, hit reaction, knockdown/ogłuszenie, wyraźne cooldowny i VFX | `CombatService.lua`, `WorldService.lua` | Wszystkie trzy style działają w Play przy opóźnieniu, bez obrażeń przez ścianę |
| AI | Lekki pościg proceduralny, nocny/dystansowy/tank | PathfindingService, patrol, ostrzeżenie, limit pościgu, powrót, pomoc frakcji | `WorldService.lua`, nowe `AIService.lua` | NPC/potwór omija przeszkodę, wraca do markeru i nie gubi celu permanentnie |
| NPC | 65 proceduralnych modeli i harmonogram markerów | R15 wygląd, faktyczne rutyny, praca/sen, teleport fallback poza wzrokiem | `WorldService.lua`, `npc_schedules.json` | Każdy wymagany NPC jest osiągalny i nie znika w pełnym dniu/nocy |
| UI | HUD, tekstowe panele, dialog, menu/pauza | Responsywne ekrany inventory/stat/journal/trainer, porównanie itemów, dostępność | `GameClient.client.lua` | PC + mały ekran: brak nakładania tekstu, wszystkie akcje dostępne bez skrótów |
| Questy | 5+5+10 danych, przyjęcie/raport, cele kandydackie, finał | Cele i alternatywne rozwiązania dla każdego questa, realne konsekwencje | `QuestService.lua`, `dialogues_*.json` | Każdy quest ma testowalny start, sukces, porażkę/nagrodę i wpis dziennika |
| Save | 3 sloty, `UpdateAsync`, schema v1 i domyślne pola | UI slotu 3 load, pozycja, NPC/loot/rutyny, pełna migracja wersji | `SaveService.lua`, `StateService.lua` | Save/load odtwarza wszystkie wymagane pola z promptu |

## P1 — potrzebne dla jakości vertical slice

| Obszar | Następne konkretne zadanie |
|---|---|
| Kradzież | Dodać zwrot przedmiotu, grzywnę, dialog strażnika, trwałą pamięć alarmu i końcową walkę; obecnie jest wykrycie, reputacja i obrażenia NPC. |
| Łup i skórowanie | Tabele zależne od gatunku, animacja, znikanie zwłok, respawn i blokada podnoszenia przez innych graczy. |
| Magia/VFX | Pociski fizyczne, cast time widoczny w HUD, ParticleEmitter ognia/lodu, trafienie i slow. |
| Opcje | Zapisywać master/music/SFX/sensitivity/subtitles/quality; UI Roblox nie kontroluje natywnie rozdzielczości lub trybu okna, więc opisać ograniczenie zamiast udawać obsługę. |
| Audio | Dodać tylko własne lub licencjonowane SFX, SoundGroup music/SFX i uzupełnić `THIRD_PARTY_ASSETS.md`. |
| Grafika | Zastąpić prymitywy modelami proceduralnymi/MeshPartami, wykonać cztery stroje gracza oraz rozpoznawalne 30 broni. |

## P2 — po stabilizacji

- Sterowanie dotykowe i gamepad przez ContextActionService.
- Ułatwienia: skalowanie tekstu, remap klawiszy, kontrast, redukcja efektów.
- Pooling VFX i profiling StreamingEnabled dla średniego PC.
- Rozszerzona lokalizacja przy pozostawieniu polskiego jako języka bazowego.

## Kolejność następnej implementacji

1. `AIService` z PathfindingService i testami powrotu do markeru.
2. `AnimationService` z własnymi identyfikatorami animacji po ich utworzeniu w Studio.
3. Pełny ekran dziennika/ekwipunku/trenera i stan HUD aktualizowany z serwera.
4. Każdy quest poboczny otrzymuje terenowy cel oraz co najmniej jedna alternatywa.
5. Private playtest, naprawa blokerów i dopiero potem deklaracja ukończenia.
