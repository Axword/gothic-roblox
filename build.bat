@echo off
echo Kompilacja danych JSON do Luau...
python tests/test_data.py
if %errorlevel% equ 0 (
    echo.
    echo [SUKCES] Dane zostały pomyślnie skompilowane i przetestowane!
    echo Wygenerowane skrypty znajdziesz w src/ReplicatedStorage/Data/Generated/
    
    echo.
    echo Sprawdzanie czy Rojo CLI jest zainstalowane...
    where rojo >nul 2>nul
    if %errorlevel% equ 0 (
        echo Wykryto Rojo CLI! Generowanie pliku projektu PograniczePopiolu.rbxl...
        rojo build -o PograniczePopiolu.rbxl default.project.json
        if exist PograniczePopiolu.rbxl (
            echo.
            echo [SUKCES] Plik PograniczePopiolu.rbxl został wygenerowany pomyślnie!
            echo Możesz go teraz otworzyć bezpośrednio w Roblox Studio.
        ) else (
            echo [OSTRZEŻENIE] Nie udało się wygenerować pliku .rbxl mimo wykrycia Rojo.
        )
    ) else (
        echo [INFO] Rojo CLI nie jest zainstalowane w Twoim systemie globalnym.
        echo Jeśli chcesz automatycznie generować pliki .rbxl jednym kliknięciem:
        echo 1. Pobierz plik 'rojo.exe' z oficjalnego GitHuba Rojo (https://github.com/rojo-rbx/rojo/releases)
        echo 2. Dodaj go do zmiennych środowiskowych PATH lub po prostu wrzuć do tego folderu.
        echo 3. Następnie uruchom ten skrypt ponownie.
        echo.
        echo Jeśli nie masz Rojo, możesz nadal bez przeszkód przenieść pliki ręcznie (Metoda 2).
    )
) else (
    echo.
    echo [BŁĄD] Wystąpił błąd podczas kompilacji. Upewnij się, że masz zainstalowanego Pythona.
)
pause
