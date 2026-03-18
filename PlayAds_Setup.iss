; ============================================================
;  PlayAds Setup — Inno Setup Script
;  Empresa: TechSolution
;  Repositorio: github.com/MicaelTech3/playAds-releasse
; ============================================================

#define AppName      "PlayAds"
#define AppVersion   "7.0"
#define AppPublisher "TechSolution"
#define AppURL       "https://playads-app.web.app"
#define AppExeName   "PlayAds.exe"
#define GitHubUser   "MicaelTech3"
#define GitHubRepo   "playAds-releasse"
#define GitHubBranch "main"

#define RawBase "https://raw.githubusercontent.com/" + GitHubUser + "/" + GitHubRepo + "/" + GitHubBranch

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
AllowNoIcons=no
SetupIconFile=logo PlayAds.ico
OutputDir=dist_installer
OutputBaseFilename=PlayAds_Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName} {#AppVersion}
VersionInfoVersion=7.0.0.0
VersionInfoCompany={#AppPublisher}
VersionInfoDescription={#AppName} Installer
VersionInfoProductName={#AppName}
MinVersion=10.0
ShowTaskbarProgressBar=yes

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon";   Description: "Criar atalho na Área de Trabalho"; GroupDescription: "Atalhos:"; Flags: checkedonce
Name: "startmenuicon"; Description: "Criar atalho no Menu Iniciar";      GroupDescription: "Atalhos:"; Flags: checkedonce

[Files]
; Ícone incluído no instalador
Source: "logo PlayAds.ico"; DestDir: "{app}"; Flags: ignoreversion

; PlayAds.exe empacotado diretamente no instalador
Source: "dist\PlayAds\PlayAds.exe"; DestDir: "{app}"; Flags: ignoreversion

; Pasta _internal completa empacotada no instalador
Source: "dist\PlayAds\_internal\*"; DestDir: "{app}\_internal"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autodesktop}\{#AppName}";       Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\logo PlayAds.ico"; Tasks: desktopicon
Name: "{group}\{#AppName}";             Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\logo PlayAds.ico"; Tasks: startmenuicon
Name: "{group}\Desinstalar {#AppName}"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Abrir {#AppName} agora"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\local"
Type: filesandordirs; Name: "{app}\_internal"
Type: files; Name: "{app}\activation.json"
Type: files; Name: "{app}\playads_config.json"
Type: files; Name: "{app}\local_playlists.json"
Type: files; Name: "{app}\local_anuncios.json"
Type: files; Name: "{app}\local_logs.json"
Type: files; Name: "{app}\local_schedules.json"
Type: files; Name: "{app}\_playads_restart.vbs"
Type: files; Name: "{app}\_playads_restart.bat"

[Code]
var
  DownloadPage: TDownloadWizardPage;
  PythonInstalled: Boolean;
  PythonExe: String;

function FindPython(): Boolean;
var
  PyPath: String;
  Versions: TArrayOfString;
  i: Integer;
begin
  Result := False;
  PythonExe := '';
  Versions := ['3.12', '3.13', '3.11', '3.10'];
  for i := 0 to GetArrayLength(Versions) - 1 do begin
    if RegQueryStringValue(HKLM, 'SOFTWARE\Python\PythonCore\' + Versions[i] + '\InstallPath', '', PyPath) then begin
      PythonExe := PyPath + 'pythonw.exe';
      if FileExists(PythonExe) then begin Result := True; Exit; end;
    end;
    if RegQueryStringValue(HKCU, 'SOFTWARE\Python\PythonCore\' + Versions[i] + '\InstallPath', '', PyPath) then begin
      PythonExe := PyPath + 'pythonw.exe';
      if FileExists(PythonExe) then begin Result := True; Exit; end;
    end;
  end;
end;

procedure InitializeWizard();
begin
  DownloadPage := CreateDownloadPage(
    'Baixando arquivos',
    'Aguarde enquanto os arquivos são baixados...',
    nil
  );
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpReady then begin
    DownloadPage.Clear;

    // Sempre baixa o player.py atualizado do GitHub
    DownloadPage.Add(
      '{#RawBase}/player.py',
      'player.py',
      ''
    );

    // Se Python não instalado, baixa o instalador
    PythonInstalled := FindPython();
    if not PythonInstalled then begin
      DownloadPage.Add(
        'https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe',
        'python_installer.exe',
        ''
      );
    end;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
begin
  Result := True;

  if CurPageID = wpReady then begin

    // Faz os downloads
    DownloadPage.Show;
    try
      try
        DownloadPage.Download;
      except
        if DownloadPage.AbortedByUser then
          Log('Download cancelado.')
        else
          SuppressibleMsgBox(
            'Falha ao baixar os arquivos.' + #13#10 +
            'Verifique sua conexão com a internet e tente novamente.',
            mbCriticalError, MB_OK, IDOK
          );
        Result := False;
        Exit;
      end;
    finally
      DownloadPage.Hide;
    end;

    // Instala Python se necessário
    if not PythonInstalled then begin
      DownloadPage.Show;
      DownloadPage.SetText('Instalando Python 3.12...', 'Isso pode levar alguns minutos...');
      if not Exec(
        ExpandConstant('{tmp}\python_installer.exe'),
        '/quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_launcher=0',
        '', SW_HIDE, ewWaitUntilTerminated, ResultCode
      ) then begin
        SuppressibleMsgBox(
          'Falha ao instalar o Python.' + #13#10 +
          'Instale manualmente em python.org e tente novamente.',
          mbCriticalError, MB_OK, IDOK
        );
        Result := False;
        DownloadPage.Hide;
        Exit;
      end;
      FindPython();
      DownloadPage.Hide;
    end;

    // Instala dependências pip
    if PythonExe <> '' then begin
      DownloadPage.Show;
      DownloadPage.SetText(
        'Instalando dependências...',
        'pywebview, pygame, requests, pycaw, yt-dlp'
      );
      Exec(
        PythonExe,
        '-m pip install pywebview pygame requests pycaw yt-dlp pythonnet --upgrade -q',
        ExpandConstant('{app}'),
        SW_HIDE, ewWaitUntilTerminated, ResultCode
      );
      DownloadPage.Hide;
    end;

    // Copia player.py para pasta de instalação
    RenameFile(
      ExpandConstant('{tmp}\player.py'),
      ExpandConstant('{app}\player.py')
    );

    // Cria pasta local/
    CreateDir(ExpandConstant('{app}\local'));
  end;
end;

function WelcomeLabel2Caption(): String;
begin
  Result :=
    'Este assistente irá instalar o PlayAds versão 7.0 no seu computador.' + #13#10 + #13#10 +
    'O PlayAds é um player profissional de anúncios de áudio com:' + #13#10 +
    '  • Reprodução agendada de anúncios' + #13#10 +
    '  • Duck automático de volume' + #13#10 +
    '  • Sincronização via Firebase' + #13#10 +
    '  • Painel web de controle' + #13#10 + #13#10 +
    'Clique em Avançar para continuar.';
end;
