[Setup]
AppName=StrokeViz
AppVersion=1.0
DefaultDirName={autopf}\StrokeViz
DefaultGroupName=StrokeViz
UninstallDisplayIcon={app}\strokeviz.exe
Compression=lzma2
SolidCompression=yes
OutputDir=.\build\installer
OutputBaseFilename=StrokeViz_Setup

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\StrokeViz"; Filename: "{app}\strokeviz.exe"
Name: "{group}\Uninstall StrokeViz"; Filename: "{uninstallexe}"
Name: "{autodesktop}\StrokeViz"; Filename: "{app}\strokeviz.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"

[Run]
Filename: "{app}\strokeviz.exe"; Description: "Launch StrokeViz"; Flags: nowait postinstall skipifsilent
