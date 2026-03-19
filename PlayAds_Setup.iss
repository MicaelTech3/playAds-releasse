; ============================================================
;  PlayAds Setup — Inno Setup Script
;  Empresa: TechSolution
;  Repositório: github.com/MicaelTech3/playAds-releasse
; ============================================================

#define AppName      "PlayAds"
#define AppVersion   "1.0"
#define AppPublisher "TechSolution"
#define AppURL       "https://playads-app.web.app"
#define AppExeName   "PlayAds.exe"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}

; ── Instalação em Program Files (read-only, só binários) ──────────────────────
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
AllowNoIcons=no
SetupIconFile=logo PlayAds.ico
OutputDir=dist_installer
OutputBaseFilename=PlayAds_Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

; Admin necessário para instalar em Program Files
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog

UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName} {#AppVersion}
VersionInfoVersion=1.0.0.0
VersionInfoCompany={#AppPublisher}
VersionInfoDescription={#AppName} Installer
VersionInfoProductName={#AppName}
MinVersion=10.0

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon";   Description: "Criar atalho na Área de Trabalho"; GroupDescription: "Atalhos:"; Flags: checkedonce
Name: "startmenuicon"; Description: "Criar atalho no Menu Iniciar";      GroupDescription: "Atalhos:"; Flags: checkedonce

[Files]
; Ícone
Source: "logo PlayAds.ico"; DestDir: "{app}"; Flags: ignoreversion

; Executável principal (apenas leitura em Program Files — OK)
Source: "dist\PlayAds\PlayAds.exe"; DestDir: "{app}"; Flags: ignoreversion

; Dependências internas do PyInstaller (apenas leitura — OK)
Source: "dist\PlayAds\_internal\*"; DestDir: "{app}\_internal"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autodesktop}\{#AppName}";       Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\logo PlayAds.ico"; Tasks: desktopicon
Name: "{group}\{#AppName}";             Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\logo PlayAds.ico"; Tasks: startmenuicon
Name: "{group}\Desinstalar {#AppName}"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Abrir {#AppName} agora"; Flags: nowait postinstall skipifsilent

; ── Desinstalação ─────────────────────────────────────────────────────────────
; {app}         = C:\Program Files (x86)\PlayAds\   → só binários, Inno já limpa
; {userappdata} = C:\Users\<user>\AppData\Roaming\  → dados do usuário, limpamos aqui
[UninstallDelete]
; Dados do usuário em APPDATA (onde o player.py realmente grava)
Type: filesandordirs; Name: "{userappdata}\{#AppName}\local"
Type: files;          Name: "{userappdata}\{#AppName}\activation.json"
Type: files;          Name: "{userappdata}\{#AppName}\playads_config.json"
Type: files;          Name: "{userappdata}\{#AppName}\local_playlists.json"
Type: files;          Name: "{userappdata}\{#AppName}\local_anuncios.json"
Type: files;          Name: "{userappdata}\{#AppName}\local_logs.json"
Type: files;          Name: "{userappdata}\{#AppName}\local_schedules.json"
Type: files;          Name: "{userappdata}\{#AppName}\_playads_restart.vbs"
Type: filesandordirs; Name: "{userappdata}\{#AppName}"

; Binários em Program Files (redundante — Inno já remove, mas por segurança)
Type: filesandordirs; Name: "{app}\_internal"

[Code]
// Nenhum download necessário — tudo está empacotado no instalador pelo PyInstaller.
// O player.py já está compilado dentro do PlayAds.exe via PyInstaller.

function WelcomeLabel2Caption(): String;
begin
  Result :=
    'Este assistente irá instalar o PlayAds versão 1.0 no seu computador.' + #13#10 + #13#10 +
    'O PlayAds é um player profissional de anúncios de áudio com:' + #13#10 +
    '  • Reprodução agendada de anúncios' + #13#10 +
    '  • Duck automático de volume' + #13#10 +
    '  • Sincronização via Firebase' + #13#10 +
    '  • Painel web de controle' + #13#10 + #13#10 +
    'Clique em Avançar para continuar.';
end;
