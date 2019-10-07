#Include %A_ScriptDir%\IncludeAll.ahk

#Include %A_ScriptDir%\UserCommands.ahk
rootCommand := CreateCommands()
main := new MainController(new Environment(), new Gui())
main.SetRootCommand(rootCommand)
extensionManager.Attach(main, {multipleUsers: {desktops: desktopUserMap}})

^/::
    main.Execute()
    return

#Include %A_ScriptDir%\src\Gui\GuiEscapes.ahk
