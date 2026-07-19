# Questy i dialogi
Graf: `quest_main_arrival → quest_main_right → [wybór kordon|wolnica] → epilog`. Dwie ukończone kandydackie misje odblokowują wybór; druga strona zostaje zablokowana flagą `faction_locked`.

Dane zawierają 5 misji Kordonu, 5 Wolnicy i 10 pobocznych. Zadania 1, 3 i 5 obu dróg mają oznaczenie `branching`: rozwiązanie walką, układem lub dowodem zmienia reputację/nagrodę w pełnej implementacji. Dialogi są w `dialogues_*.json` jako węzły, odpowiedzi i akcje. Każdy węzeł ma wyjście `close`; nie ma pułapki dialogowej.
