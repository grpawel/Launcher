#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\UserGuard.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\SetUserFromDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\AsUserOpener.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\BlockingOpener.ahk

MultipleUsersExtension(mainController) {
    mainController.UpdateEnvironment(MergeArrays({ user: ""}, AsUserOpener()))
    Command.UserConfig := Func("_Command_UserConfig")
    Command.CanRunWithUser := Func("_Command_CanRunWithUser")
}

; `config` object specifies how command interacts with current user.
; Possible values:
; 1) Block every user
; command.UserConfig({ blacklist: "all" }) 
; 2) Block only user 'user1' and 'user2', others are allowed
; command.UserConfig({ blacklist: ["user1", "user2"] }) 
; 3) Allow only 'user1', others are blocked
; command.UserConfig({ whitelist: ["user1"] }) 
; 4) Allow 'user1', but switch to 'user2' before running
; command.UserConfig({ switchFrom: ["user1"], switchTo: "user2" })
; 5) Allow all users and switch to 'user2' before running
; command.UserConfig({ switchTo: "user2" })
; 5) Combination of above. Same user in multiple options can cause unexpected results.
_Command_UserConfig(this, config) {
    this._userConfig := config
    return this
}

; returns true, false or {switchTo: username}
_Command_CanRunWithUser(this, user) {
    config := this._userConfig
    if (config == "") {
        ; no config => allowed
        return true
    }
    if (config.blacklist == "all"
        || ArrayContains(config.blacklist, user)) {
        ; user is blocked
        return false
    }
    if (ArrayContains(config.whitelist, user)) {
        ; user is specifically allowed
        return true
    }
    if (config.switchTo != "") {
        ; user has to be switched
        if (config.switchFrom == ""
            || config.switchFrom == "all"
            || ArrayContains(config.switchFrom, user)) {
            return { "switchTo": config.switchTo }
        }
    }
    return true
}
