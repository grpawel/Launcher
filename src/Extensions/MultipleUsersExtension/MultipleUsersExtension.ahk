#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\UserGuard.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\SetUserFromDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\AsUserOpener.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\BlockingOpener.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk

MultipleUsersExtension(mainController) {
    mainController.UpdateEnvironment(MergeArrays({ user: ""}, AsUserOpener()))
    Command.UserConfig := Func("_Command_UserConfig")
    Command.CanRunWithUser := Func("_Command_CanRunWithUser")
}

; `config` object specifies how command interacts with current user.
; If user is not specified, by default is allowed.
; Some examples:
; 1) Block every user
; command.UserConfig({ blacklist: "all" }) 
; 2) Block only user 'user1' and 'user2', others are allowed
; command.UserConfig({ blacklist: ["user1", "user2"] }) 
; 3) Allow only 'user1', others are blocked
; command.UserConfig({ blacklist: "all", whitelist: ["user1"] }) 
; 4) Allow 'user1', but switch to desktop for 'user2' before running
; command.UserConfig({ switchFrom: ["user1"], switchTo: "user2" })
; 5) Allow all users and switch to 'user2' before running
; command.UserConfig({ switchTo: "user2" })
; 6) Run as different user, regardless of current user
; command.UserConfig({ runAs: "user1" })
; 6) A combination of above. Same user in multiple options can cause unexpected results.
_Command_UserConfig(this, config) {
    if (this._userConfig == "") {
        this._userConfig := {}
    }
    AddAll(this._userConfig, config)
    return this
}

; returns true, false or {switchTo: username}
_Command_CanRunWithUser(this, user) {
    config := this._userConfig
    result := { block: false }
    if (config.blacklist == "all"
        || ArrayContains(config.blacklist, user)) {
        ; user is blocked
        result.block := true
    }
    if (ArrayContains(config.whitelist, user)) {
        ; user is specifically allowed
        result.block := false
    }
    if (config.HasKey("switchTo")) {
        ; user has to be switched
        if (config.switchFrom == ""
            || config.switchFrom == "all"
            || ArrayContains(config.switchFrom, user)) {
            result.switchTo := config.switchTo
        }
    }
    if (config.HasKey("runAs")) {
        result.runAs := config.runAs
    }
    return result
}
