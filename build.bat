@echo off
echo ===================================================
echo [1/2] Kompilacja danych JSON do Luau...
echo ===================================================
python tests/test_data.py
if errorlevel 1 goto ERROR_PYTHON

echo.
echo ===================================================
echo [2/2] Generowanie pliku projektu Roblox (.rbxl)...
echo ===================================================

:: Sprawdzenie lokalnego rojo.exe w tym samym katalogu
if exist "rojo.exe" (
    echo Wykryto lokalny plik rojo.exe w katalogu!
    echo Budowanie projektu do PograniczePopiolu.rbxl...
    .\rojo.exe build -o PograniczePopiolu.rbxl default.project.json
    goto CHECK_SUCCESS
)

:: Sprawdzenie globalnego rojo
where rojo >nul 2>nul
if errorlevel 1 (
    echo [INFO] Nie znaleziono instalacji Rojo (globalnej ani lokalnej).
    echo Jeśli chcesz automatycznie generować pliki .rbxl, pobierz 'rojo.exe'
    echo z oficjalnego GitHuba Rojo i wrzuc go do tego folderu (obok build.bat).
    echo Link: https://github.com/rojo-rbx/rojo/releases
    echo.
    echo Mozesz teraz skopiowac skrypty z katalogu src/ recznie do Roblox Studio (Metoda 2).
    goto END
)

echo Wykryto globalne Rojo CLI!
echo Budowanie projektu do PograniczePopiolu.rbxl...
rojo build -o PograniczePopiolu.rbxl default.project.json

:CHECK_SUCCESS
if exist "PograniczePopiolu.rbxl" (
    echo.
    echo [SUKCES] Plik PograniczePopiolu.rbxl zostal wygenerowany pomyslnie!
    echo Mozesz go teraz otworzyc bezposrednio w Roblox Studio.
) else (
    echo [BLAD] Nie udalo sie wygenerowac pliku .rbxl.
)
goto END

:ERROR_PYTHON
echo.
echo [BLAD] Kompilacja danych nie powiodla sie.
echo Upewnij sie, ze masz zainstalowany program Python.

:END
echo.
pause
