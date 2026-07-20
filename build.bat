@echo off
echo Kompilacja danych JSON do Luau...
python tests/test_data.py
if %errorlevel% equ 0 (
    echo.
    echo [SUKCES] Dane zostały pomyślnie skompilowane i przetestowane!
    echo Wygenerowane skrypty znajdziesz w src/ReplicatedStorage/Data/Generated/
) else (
    echo.
    echo [BŁĄD] Wystąpił błąd podczas kompilacji. Upewnij się, że masz zainstalowanego Pythona.
)
pause
