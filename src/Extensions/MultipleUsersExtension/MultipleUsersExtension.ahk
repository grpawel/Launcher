#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\AsUserOpener.ahk

MultipleUsersExtension(executableService) {
    executableService.UpdateEnvironment({ user: "", Open: new AsUserOpener() })
}
