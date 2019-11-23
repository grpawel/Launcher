#Include <windows-desktop-switcher/functions>

#Include %A_ScriptDir%\src\Extensions\ExtensionManager.ahk
#Include %A_ScriptDir%\src\Extensions\Extension.ahk

#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\CreateDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\DeleteDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Functions\ValueFunctions.ahk

ExtensionManager.RegisterExtension(DesktopsExtension)

class DesktopsExtension extends Extension {
    static NAME := "desktops"

    Activate(extensions) {
        if (extensions.HasKey("commandsFile")) {
            this._RegisterCommands(extensions["commandsFile"])
        }
    }

    _RegisterCommands(commandsFileExt) {
        commandsFileExt.RegisterCommand("ChangeDesktop", "Change desktop", ["Desktop number"])
        commandsFileExt.RegisterCommand("CreateDesktop", "Create new desktop", [])
        commandsFileExt.RegisterCommand("DeleteDesktop", "Delete current desktop", [])
    }
}
