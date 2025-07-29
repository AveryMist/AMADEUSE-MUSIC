[Setup]
AppId=B9F6E402-0CAE-4045-BDE6-14BD6C39C4EA
AppVersion=1.12.0+25
AppName=AMADEUSE MUSIC
AppPublisher=anandnet
AppPublisherURL=https://github.com/anandnet/amadeuse-Music
AppSupportURL=https://github.com/anandnet/amadeuse-Music
AppUpdatesURL=https://github.com/anandnet/amadeuse-Music
DefaultDirName={autopf}\amadeusemusic
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=amadeusemusic-1.12.0
Compression=lzma
SolidCompression=yes
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
WizardStyle=modern
PrivilegesRequired=lowest
LicenseFile=..\..\LICENSE
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\amadeusemusic.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\AMADEUSE MUSIC"; Filename: "{app}\amadeusemusic.exe"
Name: "{autodesktop}\AMADEUSE MUSIC"; Filename: "{app}\amadeusemusic.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\amadeusemusic.exe"; Description: "{cm:LaunchProgram,{#StringChange('AMADEUSE MUSIC', '&', '&&')}}"; Flags: nowait postinstall skipifsilent
