#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\SetUserFromDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\AsUserOpener.ahk

MultipleUsersExtension(mainController) {
    mainController.UpdateEnvironment({ user: "", Open: new AsUserOpener() })
}
