; Created by Asger Juul Brunshøj

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn, All  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance

#Include %A_ScriptDir%\src\Commands\ImportCommands.ahk

#Include %A_ScriptDir%\src\MainController.ahk
#Include %A_ScriptDir%\src\Environment\Environment.ahk
#Include %A_ScriptDir%\src\Gui\Gui.ahk

#Include %A_ScriptDir%\src\Extensions\RegisterExtensions.ahk
extensionManager := new ExtensionManager()
extensionManager.RegisterExtensions()

#Include %A_ScriptDir%\UserFunctions.ahk
#Include %A_ScriptDir%\UserCommands.ahk
rootCommand := CreateCommands()
main := new MainController(new Environment(), new Gui())
main.SetRootCommand(rootCommand)
extensionManager.Attach(main, {multipleUsers: {desktops: desktopUserMap}})

^/::
    main.Execute()
    return

#Include %A_ScriptDir%\src\Gui\GuiEscapes.ahk
