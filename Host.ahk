; Created by Asger Juul Brunshøj

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn, All  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance

SetCapsLockState, AlwaysOff

#Include %A_ScriptDir%\src\Commands\ImportCommands.ahk

#Include %A_ScriptDir%\src\MainController.ahk
#Include %A_ScriptDir%\src\Environment\Environment.ahk
#Include %A_ScriptDir%\src\Gui\Gui.ahk
global main := new MainController(new Environment(), new Gui())

#Include %A_ScriptDir%\src\Extensions\RegisterExtensions.ahk
RegisterExtensions(main)

#Include %A_ScriptDir%\UserFunctions.ahk
UserFunctions(main)
#Include %A_ScriptDir%\UserCommands.ahk
main.SetRootCommand(CreateCommands())

CapsLock & Space::
    main.GetGui().ToggleWindow()
    if (main.GetGui().IsVisible()) {
        main.RunRootCommand()
    }
    return

#Include %A_ScriptDir%\src\Gui\CapsLockFunctionality.ahk
