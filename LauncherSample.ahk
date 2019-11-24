; Sample root file.
; To change hotkeys and other configuration copy it into main folder.

#Include %A_ScriptDir%\src\IncludeAll.ahk
 
 ; Change this file to your copy of CommandsSample.ahk
#Include %A_ScriptDir%\UserConfig\CommandsSample.ahk
rootCommand := CreateCommands()

main := new Controller(new Environment(), new Gui())
main.SetRootCommand(rootCommand)
; Uncomment to enable extensions
/*
main.GetExtensionManager().AttachAll().Activate()
*/

; Ctrl+/
^/::
    main.Execute()
    return

#Include %A_ScriptDir%\src\Gui\GuiEscapes.ahk
