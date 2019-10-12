#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\UserGuard.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\SetUserFromDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\AsUserOpener.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\BlockingOpener.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk
#Include %A_ScriptDir%\src\Utils\CommandUtils.ahk

extensionManager.RegisterExtension(new MultipleUsersExtension())

class MultipleUsersExtension {
    name := "multipleUsers"

    __New() {
        Command.UserConfig := Func("_Command_UserConfig")
        Command.RunAs := Func("_Command_RunAs")
        Command.CanRunWithUser := Func("_Command_CanRunWithUser")
    }

    Attach(controller, availableExtensions, settings = "") {
        desktopToUserMap := settings.desktopToUserMap
        if (availableExtensions.HasKey("desktops")) {
            this._DesktopsCompat(controller, desktopToUserMap)
        }
        guard := new UserGuard(desktopToUserMap)
        controller.SubscribeCommandAboutToRun(BindControllerToCommand(guard, controller))

        controller.UpdateEnvironment(MergeArrays({ user: ""}, AsUserOpener()))
    }

    _DesktopsCompat(controller, desktopToUserMap) {
        if (desktopToUserMap != "") {
            userSetter := new SetUserFromDesktop(desktopToUserMap)
            controller.SubscribeRootCommandAboutToRun(BindControllerToCommand(userSetter, controller))
        }
        
    }
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
; 7) A combination of above. Same user in multiple options can cause unexpected results.
_Command_UserConfig(this, config) {
    static V := new ValidatorFactory()
    static VAL := V.Object( { "blacklist": V.Or([V.Equal("all"), V.ObjectEachValue(V.String())])
                            , "whitelist": V.Or([V.Equal("all"), V.ObjectEachValue(V.String())])
                            , "runAs": V.String()
                            , "switchFrom": V.ObjectEachValue(V.String())
                            , "switchTo": V.String() }
                        , {ignoreMissing: true, noOtherKeys: false} )
    if (this._userConfig == "") {
        this._userConfig := {}
    }
    AddAll(this._userConfig, config)
    VAL.ValidateAndShow(this._userConfig)
    return this
}

; Shortcut method for user config
_Command_RunAs(this, userName) {
    return this.UserConfig({"runAs": userName})
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
