; Created by Asger Juul Brunshøj

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance

SetCapsLockState, AlwaysOff

#Include %A_ScriptDir%\src\Events\EventBus.ahk
global globalEventBus := new EventBus()

#Include %A_ScriptDir%\src\Commands\ImportCommands.ahk

#Include %A_ScriptDir%\src\Environment\Environment.ahk
environment := new Environment()

#Include %A_ScriptDir%\src\MainController.ahk
global mainController := new MainController(environment)

#Include %A_ScriptDir%\src\Extensions\RegisterExtensions.ahk
RegisterExtensions(mainController)

#Include %A_ScriptDir%\UserCommands.ahk
rootCommand := CreateCommands()

mainController.SetRootCommand(rootCommand)

#Include %A_ScriptDir%\src\Gui\Colors.ahk

; #InstallKeybdHook

;-------------------------------------------------------
; AUTO EXECUTE SECTION FOR INCLUDED SCRIPTS
; Scripts being included need to have their auto execute
; section in a function or subroutine which is then
; executed below.
;-------------------------------------------------------
Gosub, gui_autoexecute
;-------------------------------------------------------
; END AUTO EXECUTE SECTION
return
;-------------------------------------------------------

; Load the GUI code
#Include %A_ScriptDir%\src\GuiLauncher.ahk

; General settings
#Include %A_ScriptDir%\src\Utils\Utils.ahk
