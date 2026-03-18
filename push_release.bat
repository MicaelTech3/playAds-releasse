@echo off
:: ============================================================
::  push_release.bat
::  Limpa arquivos gerados, compila e faz git push
::  Execute na pasta raiz do projeto de release
:: ============================================================

echo.
echo  =====================================
echo   PlayAds - Preparando Push Release
echo  =====================================
echo.

:: ── 1. Limpa arquivos gerados em runtime ──────────────────
echo [1/5] Limpando arquivos temporarios...

if exist "activation.json"        del /Q "activation.json"
if exist "playads_config.json"     del /Q "playads_config.json"
if exist "local_playlists.json"    del /Q "local_playlists.json"
if exist "local_anuncios.json"     del /Q "local_anuncios.json"
if exist "local_logs.json"         del /Q "local_logs.json"
if exist "local_schedules.json"    del /Q "local_schedules.json"
if exist "_playads_restart.vbs"    del /Q "_playads_restart.vbs"
if exist "_playads_restart.bat"    del /Q "_playads_restart.bat"
if exist "_playads_fb.bat"         del /Q "_playads_fb.bat"

:: Limpa pasta local/ mas mantém ela existindo
if exist "dist\PlayAds\local\" (
    del /Q /S "dist\PlayAds\local\*.*" 2>NUL
)
if exist "local\" (
    del /Q /S "local\*.*" 2>NUL
)

:: Limpa __pycache__
if exist "__pycache__" rmdir /Q /S "__pycache__"
if exist "dist\PlayAds\__pycache__" rmdir /Q /S "dist\PlayAds\__pycache__"

echo       Limpeza concluida!

:: ── 2. Copia player.py atualizado para dist ───────────────
echo [2/5] Atualizando player.py na pasta dist...
if exist "player.py" (
    copy /Y "player.py" "dist\PlayAds\player.py" >NUL
    echo       player.py copiado para dist\PlayAds\
)

:: ── 3. Pergunta a mensagem do commit ──────────────────────
echo.
echo [3/5] Mensagem do commit:
set /P COMMIT_MSG="  Digite (ex: v7.0 - correcao restart): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=update

:: ── 4. Git add, commit e push ─────────────────────────────
echo.
echo [4/5] Fazendo git add + commit + push...

git add .
git commit -m "%COMMIT_MSG%"
git push

if errorlevel 1 (
    echo.
    echo  ERRO no git push! Verifique:
    echo  - Se o repositorio remoto esta configurado
    echo  - Se voce tem permissao de push
    echo  - Se esta conectado a internet
    echo.
    pause
    exit /b 1
)

:: ── 5. Concluido ──────────────────────────────────────────
echo.
echo [5/5] Push realizado com sucesso!
echo.
echo  Repositorio atualizado:
echo https://github.com/MicaelTech3/playAds-releasse
echo.
echo  Lembre de criar um novo Release no GitHub se necessario:
echo https://github.com/MicaelTech3/playAds-releasse
echo.
pause
