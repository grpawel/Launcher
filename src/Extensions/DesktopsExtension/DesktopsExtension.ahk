#Include <windows-desktop-switcher/functions>

#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\CreateDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\DeleteDesktop.ahk

class DesktopsExtension {
    name := "desktops"

    Register() {
        MainController.GetDesktop := Func("mainController_GetDesktop")
    }
}

mainController_GetDesktop(self) {
    mapDesktopsFromRegistry()
    global CurrentDesktop
    return CurrentDesktop
}