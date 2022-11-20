Unicode true ; The Multi-Language-Part is a modified version of the MultiLanguage-NSIS-Example

!define PRODUCT_VERSION "1.0.0"
!define VERSION "1.0.0"

VIProductVersion "${PRODUCT_VERSION}"
VIFileVersion "${VERSION}"

VIAddVersionKey "ProductName" "Portmaster"
VIAddVersionKey "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "FileDescription" "Portmaster Application Firewall"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "CompanyName" "Safing ICS Technologies GmbH"
VIAddVersionKey "LegalCopyright" "Safing ICS Technologies GmbH"

!define MUI_ICON "portmaster.ico"
!define MUI_UNICON "portmaster.ico"
!define MUI_HEADERIMAGE

!include MUI2.nsh
!include nsDialogs.nsh
!include LogicLib.nsh
!include WinVer.nsh
!include x64.nsh
!include shortcut-properties.nsh

Name "Portmaster"

!ifdef UNINSTALLER
	SilentInstall silent
	OutFile "uninstaller_pkg.exe"
	SetCompress off
!endif
!ifdef INSTALLER
	OutFile "portmaster-installer.exe"

	!ifdef PRODUCTION
		SetCompressor /SOLID lzma
	!else
		SetCompress off
	!endif
!endif

#InstallDir "$Programfiles64\Safing\Portmaster"
!define ProgrammFolderLink "$Programfiles64\Safing\Portmaster.lnk"
!define Parent_ProgrammFolderLink "$Programfiles64\Safing"
!define ExeName "portmaster-start.exe"
!define LogoName "portmaster.ico"
!define SnoreToastExe "SnoreToast.exe"

!define MUI_ABORTWARNING
!define MUI_LANGDLL_ALLLANGUAGES ; The Multi-Language-Part is a modified version of the MultiLanguage-NSIS-Example

Var InstDir_parent

;;
; Pages
;;
;!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
;!insertmacro MUI_PAGE_COMPONENTS
;!insertmacro MUI_PAGE_DIRECTORY
Page custom fnc_PageSummary_Show
!insertmacro MUI_PAGE_INSTFILES
Page custom fnc_PageFinish_Show
!insertmacro MUI_PAGE_FINISH

; Uninstaller Pages
!ifdef UNINSTALLER
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!endif

!include languages.nsh

Function fnc_PageSummary_Show
	nsDialogs::Create 1018
	Pop $0
	${If} $0 == error
		Abort
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "Install Summary" ""

	nsDialogs::CreateControl "RichEdit20A"	${ES_READONLY}|${WS_VISIBLE}|${WS_CHILD}|${WS_TABSTOP}|${WS_VSCROLL}|${ES_MULTILINE}|${ES_WANTRETURN} ${WS_EX_STATICEDGE} 0 0 100% 119u ''
	Pop $0
	!include install_summary.nsh

	nsDialogs::Show
FunctionEnd

Function fnc_PageFinish_Show
	nsDialogs::Create 1018
	Pop $0
	${If} $0 == error
		Abort
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "Install Successfull" ""

	nsDialogs::CreateControl "RichEdit20A"	${ES_READONLY}|${WS_VISIBLE}|${WS_CHILD}|${WS_TABSTOP}|${WS_VSCROLL}|${ES_MULTILINE}|${ES_WANTRETURN} ${WS_EX_STATICEDGE} 0 0 100% 119u ''
	Pop $0
	!include install_finish.nsh

	nsDialogs::Show
FunctionEnd

Function .onInit
	ReadEnvStr $0 PROGRAMDATA
	StrCpy $InstDir "$0\Safing\Portmaster"
	StrCpy $InstDir_parent "$0\Safing"
	SetRebootFlag true
FunctionEnd

Function un.onInit
	ReadEnvStr $0 PROGRAMDATA
	StrCpy $InstDir "$0\Safing\Portmaster"
	StrCpy $InstDir_parent "$0\Safing"
	SetRebootFlag true
FunctionEnd

!ifdef INSTALLER 
Section "Install"
	SetOutPath $INSTDIR

	SetShellVarContext all

	IfFileExists "$Programfiles64\Safing\Portmaster" 0 noAncientUpdate
		DetailPrint "Removing old Portmaster Files"
		
		RMDIR /R "$SMPROGRAMS\Portmaster"
		Delete "$SMSTARTUP\Portmaster Notifier.lnk"
		RMDir /R /REBOOTOK "$Programfiles64\Safing\Portmaster"
noAncientUpdate:	

	IfFileExists "$INSTDIR\${ExeName}" 0 dontUpdate
		DetailPrint "Removing old Portmaster Files"

		; The Exe already exists, so we will have to move the old exe first
		Delete "$INSTDIR\${ExeName}.bak"
		Rename "$INSTDIR\${ExeName}" "$INSTDIR\${ExeName}.bak"
		Delete /REBOOTOK "$INSTDIR\${ExeName}.bak"
dontUpdate:	
	File "${ExeName}"

	File "${LogoName}"
	File "portmaster-uninstaller.exe"
	
	CreateDirectory "${Parent_ProgrammFolderLink}"
	CreateShortcut "${ProgrammFolderLink}" "$InstDir"
	
	SetShellVarContext all
	CreateDirectory "$SMPROGRAMS\Portmaster"
	CreateShortcut "$SMPROGRAMS\Portmaster\Portmaster.lnk" "$INSTDIR\${ExeName}" "app --data=$InstDir" "$INSTDIR\portmaster.ico"
	CreateShortcut "$SMPROGRAMS\Portmaster\Portmaster Notifier.lnk" "$INSTDIR\${ExeName}" "notifier --data=$InstDir" "$INSTDIR\portmaster.ico"
	CreateShortcut "$SMSTARTUP\Portmaster Notifier.lnk" "$INSTDIR\${ExeName}" "notifier --data=$InstDir" "$INSTDIR\portmaster.ico"

; The GUID can be read out like this: strings snoretoast.exe | grep -E '^\{[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}\}$' (maybe additional lines with false-positives)
	!insertmacro ShortcutSetToastProperties "$SMPROGRAMS\Portmaster\Portmaster.lnk" "{7F00FB48-65D5-4BA8-A35B-F194DA7E1A51}" "io.safing.portmaster"
	pop $0
	${If} $0 <> 0
		MessageBox MB_ICONEXCLAMATION "Shortcut-Attributes to enable Toast Messages could not be set"
		SetErrors
		Abort
	${EndIf}
	DetailPrint "Sucessfully added Shortcut-Attributes for Toast Messages. Return Code: $0 (0: S_OK)"

	WriteRegStr HKLM "SOFTWARE\Classes\CLSID\{7F00FB48-65D5-4BA8-A35B-F194DA7E1A51}\LocalServer32" "" '"$INSTDIR\${ExeName}" notifier-snoretoast'

; prepare directory structure
	nsExec::ExecToStack '$INSTDIR\${ExeName} clean-structure --data=$InstDir'
	pop $0
	pop $1
	; we ignore the error here as a reboot is suggested anyway and that will
	; fix the above error as well.
	DetailPrint "Prepared the installation directory."

; download
	DetailPrint "Downloading Portmaster (~300MB), depending on download speeds this may take a while ..."
	nsExec::ExecToStack '$INSTDIR\${ExeName} update --data=$InstDir'
	pop $0
	pop $1
	; DetailPrint $1 ; # would print > BOF from portmaster-start log
	${If} $0 <> 0
		MessageBox MB_ICONEXCLAMATION "Failed to download Portmaster assets required for installation. Please check your Internet connection and try installing again."
		SetErrors
		Abort
	${EndIf}
	DetailPrint "Sucessfully downloaded Portmaster."

; register Service
	nsExec::ExecToStack '$INSTDIR\${ExeName} install core-service --data=$InstDir'
	pop $0
	pop $1
	DetailPrint $1
	${If} $0 <> 0
		MessageBox MB_ICONEXCLAMATION "Windows Service registration failed. Please contact our support at support@safing.io."
		SetErrors
		Abort
	${EndIf}
	DetailPrint "Successfully registered Portmaster as a Windows Service."

	;Actually gets placed at HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster because NSIS is 32 Bit
	;WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
	;	"InstallDate" "" ; TODO
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"DisplayName" "Portmaster"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"DisplayVersion" "${PRODUCT_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"UninstallString" "$\"$INSTDIR\portmaster-uninstaller.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"DisplayIcon" "$\"$INSTDIR\portmaster.ico$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"Publisher" "Safing ICS Technologies GmbH"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"HelpLink" "https://safing.io"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"NoRepair" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"NoModify" 1

SectionEnd

!endif

!ifdef UNINSTALLER
Section "Uninstaller"
	WriteUninstaller "$EXEDIR\portmaster-uninstaller.exe"
SectionEnd

;TODO: Double-check if everything is removed
Section Un.Portmaster SectionPortmaster
	SectionIn RO
	SetShellVarContext all

; unregister Service
	nsExec::ExecToStack '$INSTDIR\${ExeName} uninstall core-service --data=$InstDir'
	pop $0
	pop $1
	DetailPrint $1
	${If} $0 <> 0
		MessageBox MB_ICONEXCLAMATION "Deleting service was unsuccessfull, see details."
		SetErrors
		Abort
	${EndIf}
	Delete "$SMSTARTUP\Portmaster Notifier.lnk"
	
	DeleteRegKey HKLM "SOFTWARE\Classes\CLSID\{7F00FB48-65D5-4BA8-A35B-F194DA7E1A51}\LocalServer32"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster"
	
	Delete "${ProgrammFolderLink}"
	RMDir "${Parent_ProgrammFolderLink}"
	RMDIR /R "$SMPROGRAMS\Portmaster"
	RMDIR /R /REBOOTOK "$InstDir\updates"
	Delete /REBOOTOK "$InstDir\portmaster-start.exe"
	Delete /REBOOTOK "$InstDir\portmaster-uninstaller.exe"
	Delete /REBOOTOK "$InstDir\portmaster.ico"
SectionEnd

Section Un.Data SectionData
	RMDIR /R /REBOOTOK "$InstDir"
	RMDIR /REBOOTOK "$InstDir_parent"
SectionEnd

!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SectionData} "Permanently delete all user-configured global settings and application settings, as well as logs and caches."
!insertmacro MUI_DESCRIPTION_TEXT ${SectionPortmaster} "Uninstall Portmaster from Windows and remove system integrations such as shortcuts, registry keys and services."
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END
!endif
