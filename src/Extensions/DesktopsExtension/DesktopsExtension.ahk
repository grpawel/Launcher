#Include <windows-desktop-switcher/functions>

#Include %A_ScriptDir%\src\Extensions\ExtensionManager.ahk

#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\CreateDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\DeleteDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Functions\ValueFunctions.ahk

ExtensionManager.RegisterExtension(DesktopsExtension)

class DesktopsExtension {
    static NAME := "desktops"

    Attach(contr) {
        commandsFileExt := contr.GetExtension("commandsFile")
        if (commandsFileExt != "") {
            this._RegisterCommands(commandsFileExt)
        }
    }

    _RegisterCommands(commandsFileExt) {
        commandsFileExt.RegisterCommand("ChangeDesktop", "Change desktop", ["Desktop number"])
        commandsFileExt.RegisterCommand("CreateDesktop", "Create new desktop", [])
        commandsFileExt.RegisterCommand("DeleteDesktop", "Delete current desktop", [])
    }
}
