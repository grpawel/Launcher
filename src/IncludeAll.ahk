; Created by Asger Juul Brunshøj

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn, All  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance

#Include %A_ScriptDir%\src\Validation\Validators.ahk
#Include %A_ScriptDir%\src\Commands\ImportCommands.ahk
#Include %A_ScriptDir%\src\Environment\ImportFunctions.ahk
#Include %A_ScriptDir%\src\Functions\Functions.ahk
#Include %A_ScriptDir%\src\Functions\Predicates.ahk
#Include %A_ScriptDir%\src\Commands\CommandFactory.ahk

#Include %A_ScriptDir%\src\Controller\Controller.ahk
#Include %A_ScriptDir%\src\Environment\Environment.ahk
#Include %A_ScriptDir%\src\Gui\Gui.ahk

#Include %A_ScriptDir%\src\Controller\ExtensionManager.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\DesktopsExtension.ahk
#Include %A_ScriptDir%\src\Extensions\UsersExtension\UsersExtension.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\CommandsFileExtension.ahk
