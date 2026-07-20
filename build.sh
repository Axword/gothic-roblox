#!/bin/bash
echo "Kompilacja danych JSON do Luau..."
python3 tests/test_data.py
if [ $? -eq 0 ]; then
    echo ""
    echo "[SUKCES] Dane zostały pomyślnie skompilowane i przetestowane!"
    echo "Wygenerowane skrypty znajdziesz w src/ReplicatedStorage/Data/Generated/"
else
    echo ""
    echo "[BŁĄD] Wystąpił błąd podczas kompilacji. Upewnij się, że masz zainstalowanego Pythona."
fi
