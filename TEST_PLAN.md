# Plan testów
Automatycznie: `python tests/test_data.py` uruchamia generator, sprawdza referencje, minima i formułę HP. Przed merge uruchomić też `git diff --check`.

Smoke Studio (do wykonania): nowa gra → Borzuj/E → dialog → skrzynia/E → A,D,A → F5; restart → load. Regresja pełna po implementacji P0: tutorial, oba łańcuchy kandydackie, trening, każdy styl walki, zamek I–III i błąd, kradzież z/bez świadka, skórowanie, wybór, epilog oraz wszystkie sloty. Testować invalid Remote payload, spam >12/s, zły dystans i brak many/amunicji.

Dodatkowa regresja: u Żaby kupić skórowanie po zdobyciu PN/żużlu, zabić Żarłacza, użyć G i sprawdzić pojedynczy łup; przy każdym nauczycielu spróbować treningu z odległości i bez PN; otworzyć skrzynie I–III po odpowiedniej randze oraz ponownie spróbować tej samej skrzyni.

Przepływ dialogowy: porozmawiać z Borzujem/Runa, wybrać kandydackie zlecenie, oddać raport, ukończyć dwa zlecenia i sprawdzić epilog po przysiędze. U Karpa: przyjąć/oddać `quest_side_09`, odebrać Żarzący Grot i zweryfikować koszt many. Wysłać indeks odpowiedzi poza 1–8 i bez aktywnego dialogu — stan nie może się zmienić.

Cele kandydackie: przyjąć zadanie, użyć Promptu właściwego dowodu (albo zabić Żarłacza dla `quest_new_01`), sprawdzić stan `ready`, następnie oddać raport. Próba raportu przed celem musi pozostać bez nagrody.
