#Include <windows-desktop-switcher/functions>

#Include %A_ScriptDir%\src\Extensions\ExtensionManager.ahk

#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\CreateDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\DeleteDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Functions\GetDesktop.ahk

ExtensionManager.RegisterExtension(DesktopsExtension)

class DesktopsExtension {
    static NAME := "desktops"
}
