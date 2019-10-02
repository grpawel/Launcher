#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\UserGuard.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\SetUserFromDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\AsUserOpener.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\BlockingOpener.ahk

MultipleUsersExtension(mainController) {
    mainController.UpdateEnvironment(MergeArrays({ user: ""}, AsUserOpener()))
    Command.GetAllowedUsers := Func("_Command_GetAllowedUsers")
    Command.SetAllowedUsers := Func("_Command_SetAllowedUsers")
}

_Command_GetAllowedUsers(this) {
    return this._allowedUsers
}

_Command_SetAllowedUsers(this, allowedUsers) {
    if (!IsArray(allowedUsers)) {
        allowedUsers := [allowedUsers]
    }
    this._allowedUsers := allowedUsers
    return this
}