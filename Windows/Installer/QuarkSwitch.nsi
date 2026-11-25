Unicode true
!include "MUI2.nsh"

!ifndef VERSION
  !define VERSION "1.0.0"
!endif
!ifndef SOURCE_DIR
  !define SOURCE_DIR "..\QuarkSwitch.Windows\bin\Release\net10.0-windows\win-x64\publish"
!endif
!ifndef OUTPUT_FILE
  !define OUTPUT_FILE "..\..\dist-windows\QuarkSwitch-Setup-${VERSION}-x64.exe"
!endif

Name "QuarkSwitch"
OutFile "${OUTPUT_FILE}"
InstallDir "$LOCALAPPDATA\Programs\QuarkSwitch"
InstallDirRegKey HKCU "Software\Quarks\QuarkSwitch" "InstallDir"
RequestExecutionLevel user
Icon "..\QuarkSwitch.Windows\Assets\QuarkSwitch.ico"
UninstallIcon "..\QuarkSwitch.Windows\Assets\QuarkSwitch.ico"
VIProductVersion "1.0.0.0"
VIAddVersionKey "ProductName" "QuarkSwitch"
VIAddVersionKey "CompanyName" "Quarks"
VIAddVersionKey "LegalCopyright" "Copyright © Quarks"
VIAddVersionKey "FileDescription" "QuarkSwitch installer"
VIAddVersionKey "FileVersion" "${VERSION}"

!define MUI_ABORTWARNING
!define MUI_ICON "..\QuarkSwitch.Windows\Assets\QuarkSwitch.ico"
!define MUI_UNICON "..\QuarkSwitch.Windows\Assets\QuarkSwitch.ico"
!define MUI_FINISHPAGE_RUN "$INSTDIR\QuarkSwitch.exe"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Russian"

Section "QuarkSwitch" MainSection
  SetOutPath "$INSTDIR"
  File "${SOURCE_DIR}\QuarkSwitch.exe"
  CreateDirectory "$SMPROGRAMS\QuarkSwitch"
  CreateShortcut "$SMPROGRAMS\QuarkSwitch\QuarkSwitch.lnk" "$INSTDIR\QuarkSwitch.exe"
  CreateShortcut "$DESKTOP\QuarkSwitch.lnk" "$INSTDIR\QuarkSwitch.exe"
  WriteRegStr HKCU "Software\Quarks\QuarkSwitch" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\QuarkSwitch" "DisplayName" "QuarkSwitch"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\QuarkSwitch" "DisplayIcon" "$INSTDIR\QuarkSwitch.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\QuarkSwitch" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\QuarkSwitch" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\QuarkSwitch" "Publisher" "Quarks"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
  Delete "$INSTDIR\QuarkSwitch.exe"
  Delete "$INSTDIR\Uninstall.exe"
  Delete "$SMPROGRAMS\QuarkSwitch\QuarkSwitch.lnk"
  RMDir "$SMPROGRAMS\QuarkSwitch"
  Delete "$DESKTOP\QuarkSwitch.lnk"
  RMDir "$INSTDIR"
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "QuarkSwitch"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\QuarkSwitch"
  DeleteRegKey HKCU "Software\Quarks\QuarkSwitch"
SectionEnd
