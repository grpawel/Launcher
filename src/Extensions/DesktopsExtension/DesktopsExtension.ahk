#Include <windows-desktop-switcher/functions>

#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk

DesktopsExtension(mainController) {
    mainController.base.GetDesktop := Func("mainController_GetDesktop")
}

mainController_GetDesktop(self) {
    mapDesktopsFromRegistry()
    global CurrentDesktop
    return CurrentDesktop
}