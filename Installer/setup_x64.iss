[Setup]
AppName=Resource Alchemy Hacker
AppVersion=1.4.0.7
AppPublisher=EliteSoftwareTech Co.
DefaultDirName={commonpf}\EliteSoftware\Resource Alchemy Hacker
DefaultGroupName=EliteSoftware\Resource Alchemy Hacker
OutputDir=.
OutputBaseFilename=ResourceAlchemyHacker_Installer_x64_1.4.0.7
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible
DisableProgramGroupPage=yes
DisableDirPage=no

[Files]
Source: "..\x64\Release\ResourceAlchemyHacker_CLI.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\x64\Release\ResourceAlchemyHacker_GUI.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\x64\Release\ResourceAlchemyHacker_ShellExt.dll"; DestDir: "{app}"; Flags: regserver ignoreversion restartreplace uninsrestartdelete

[InstallDelete]
Type: files; Name: "{app}\*.exe"
Type: files; Name: "{app}\*.dll"

[Icons]
Name: "{group}\Resource Alchemy Hacker"; Filename: "{app}\ResourceAlchemyHacker_GUI.exe"; WorkingDir: "{app}"
Name: "{commondesktop}\Resource Alchemy Hacker"; Filename: "{app}\ResourceAlchemyHacker_GUI.exe"; WorkingDir: "{app}"

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
var
  ErrorCode: Integer;
begin
  if CurStep = ssInstall then
  begin
    if FileExists(ExpandConstant('{app}\ResourceAlchemyHacker_ShellExt.dll')) then
    begin
      Exec(ExpandConstant('{sys}\regsvr32.exe'), ExpandConstant('/u /s "{app}\ResourceAlchemyHacker_ShellExt.dll"'), '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
    end;
  end;
end;

