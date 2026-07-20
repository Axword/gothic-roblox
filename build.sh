#!/bin/bash
echo "Kompilacja danych JSON do Luau..."
python3 tests/test_data.py
if [ $? -eq 0 ]; then
    echo ""
    echo "[SUKCES] Dane zostały pomyślnie skompilowane i przetestowane!"
    echo "Wygenerowane skrypty znajdziesz w src/ReplicatedStorage/Data/Generated/"
    
    echo ""
    echo "Sprawdzanie czy Rojo CLI jest zainstalowane..."
    if command -v rojo &> /dev/null; then
        echo "Wykryto Rojo CLI! Generowanie pliku projektu PograniczePopiolu.rbxl..."
        rojo build -o PograniczePopiolu.rbxl default.project.json
        if [ -f PograniczePopiolu.rbxl ]; then
            echo ""
            echo "[SUKCES] Plik PograniczePopiolu.rbxl został wygenerowany pomyślnie!"
            echo "Możesz go teraz otworzyć bezpośrednio w Roblox Studio."
        else
            echo "[OSTRZEŻENIE] Nie udało się wygenerować pliku .rbxl mimo wykrycia Rojo."
        fi
    else
        echo "[INFO] Rojo CLI nie jest zainstalowane w Twoim systemie."
        echo "Aby wygenerować plik .rbxl automatycznie, zainstaluj Rojo CLI."
        echo "Możesz też skopiować wygenerowane pliki ręcznie do Roblox Studio."
    fi
else
    echo ""
    echo "[BŁĄD] Wystąpił błąd podczas kompilacji. Upewnij się, że masz zainstalowanego Pythona."
fi
