#Include %A_ScriptDir%\src\Extensions\UsersExtension\Commands\Actions\ChangeDesktopFromUserConfig.ahk
#Include %A_ScriptDir%\src\Extensions\UsersExtension\Commands\Actions\SetUserFromDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\UsersExtension\Commands\Actions\SetUserFromUserConfig.ahk
#Include %A_ScriptDir%\src\Extensions\UsersExtension\Commands\Blockers\IsUserAllowed.ahk
#Include %A_ScriptDir%\src\Extensions\UsersExtension\Environment\Openers\AsUserOpener.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk
#Include %A_ScriptDir%\src\Utils\CommandUtils.ahk

extensionManager.RegisterExtension(new UsersExtension())

class UsersExtension {
    name := "users"

    static PRIORITIES := { "desktopFromCommandConfig": 8
                         , "userFromDesktop": 16
                         , "userFromCommandConfig": 24 }

    __New() {
        Command.UserConfig := Func("_Command_UserConfig")
        Command.GetUserConfig := Func("_Command_GetUserConfig")
    }

    Attach(controller, availableExtensions, settings = "") {
        desktopToUserMap := settings.desktopToUserMap
        if (availableExtensions.HasKey("desktops")) {
            this._DesktopsCompat(controller, desktopToUserMap)
        }
        controller.GetBlocker().AddBlocking(Func("IsUserAllowedBlocker"), { name: "isUserAllowed" })

        controller.UpdateEnvironment(MergeArrays({ user: ""}, AsUserOpener()))
        runAsSetter := new SetUserFromUserConfig()
        controller.SubscribeCommandAboutToRun(CommandAsSubscriber(runAsSetter, controller), {priority: this.PRIORITIES["userFromCommandConfig"]})
    }

    _DesktopsCompat(controller, desktopToUserMap) {
        if (desktopToUserMap != "") {
            desktopChanger := new ChangeDesktopFromUserConfig(desktopToUserMap)
            controller.SubscribeCommandAboutToRun(CommandAsSubscriber(desktopChanger, controller), {priority: this.PRIORITIES["desktopFromCommandConfig"]})
            ; priority for `userSetter` must be higher (means running later) than for `desktopChanger`
            ; first change desktop, then change user based on that desktop
            userSetter := new SetUserFromDesktop(desktopToUserMap)
            controller.SubscribeCommandAboutToRun(CommandAsSubscriber(userSetter, controller), {priority: this.PRIORITIES["userFromDesktop"]})
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
; 6) Run as different user (equivalent to `WithEnvironment({user: "user1"}, command))
; command.UserConfig({ runAs: "user1" })
; 7) A combination of above. Same user in multiple options can cause unexpected results.
_Command_UserConfig(this, config) {
    static V := new ValidatorFactory()
    static VAL := V.Object( { "blacklist": V.Or([V.Equal("all"), V.ObjectEachValue(V.String())])
                            , "whitelist": V.Or([V.Equal("all"), V.ObjectEachValue(V.String())])
                            , "switchFrom": V.ObjectEachValue(V.String())
                            , "switchTo": V.String()
                            , "runAs": V.String() }
                        , {ignoreMissing: true, noOtherKeys: false} )
    if (this._userConfig == "") {
        this._userConfig := {}
    }
    AddAll(this._userConfig, config)
    VAL.ValidateAndShow(this._userConfig)
    return this
}

; Shortcut for RunAs
; Replaces `.UserConfig({runAs: "user1"})` with `.RunAs("user1")`
_Command_RunAs(this, userName) {
    this.UserConfig({ runAs: userName })
    return this
}

_Command_GetUserConfig(this) {
    return this._userConfig
}
