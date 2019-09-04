#Include <windows-desktop-switcher/functions>

#Include %A_ScriptDir%\src\Executables\ExecutableService.ahk

#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Executables\CommandSet\Commands\ChangeDesktop.ahk

DesktopsExtension(executableService) {
    executableService.base.GetDesktop := Func("executableService_GetDesktop")
}

executableService_GetDesktop(self) {
    mapDesktopsFromRegistry()
    global CurrentDesktop
    return CurrentDesktop
}