#Include <windows-desktop-switcher/functions>

#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\CreateDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\DeleteDesktop.ahk

class DesktopsExtension {
    name := "desktops"

    Register() {
        Controller.GetDesktop := Func("_Controller_GetDesktop")
    }
}

_Controller_GetDesktop(self) {
    mapDesktopsFromRegistry()
    global CurrentDesktop
    return CurrentDesktop
}
