#Include <windows-desktop-switcher/functions>

#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\CreateDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\DeleteDesktop.ahk

extensionManager.RegisterExtension(new DesktopsExtension())

class DesktopsExtension {
    name := "desktops"

    __New() {
        Controller.GetDesktop := Func("_Controller_GetDesktop")
    }
}

_Controller_GetDesktop() {
    mapDesktopsFromRegistry()
    global CurrentDesktop
    return CurrentDesktop
}
