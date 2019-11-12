#Include %A_ScriptDir%\src\Extensions\ExtensionManager.ahk
#Include %A_ScriptDir%\src\Events\CommandToSubscriber.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk

#Include %A_ScriptDir%\src\Extensions\UsersExtension\Commands\ScriptInteraction\ChangeUser.ahk
#Include %A_ScriptDir%\src\Extensions\UsersExtension\Commands\Subscribing\ChangeDesktopFromUserConfig.ahk
#Include %A_ScriptDir%\src\Extensions\UsersExtension\Commands\Subscribing\SetUserFromDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\UsersExtension\Commands\Subscribing\SetUserFromUserConfig.ahk
#Include %A_ScriptDir%\src\Extensions\UsersExtension\Controller\IsUserAllowedRule.ahk
#Include %A_ScriptDir%\src\Extensions\UsersExtension\Environment\Functions\AsUserOpener.ahk

extensionManager.RegisterExtension(UsersExtension)

Command.UserConfig := Func("_Command_UserConfig")
Command.GetUserConfig := Func("_Command_GetUserConfig")
Command.RunAs := Func("_Command_RunAs")

class UsersExtension {
    static NAME := "users"

    static PRIORITIES := { "desktopFromCommandConfig": 8
                         , "userFromDesktop": 16
                         , "userFromCommandConfig": 24 }

    Attach(contr, settings = "") {
        this._settings := settings
        if (contr.GetExtensionManager().GetExtension("desktops") != "") {
            this._DesktopsCompat(contr, settings.desktopToUserMap)
        }
        commandsFileExt := contr.GetExtensionManager().GetExtension("commandsFile")
        if (commandsFileExt != "") {
            this._CommandsFileCompat(commandsFileExt)
        }
        contr.GetBlocker().AddRule(Func("IsUserAllowedRule"), { name: "isUserAllowed" })

        contr.GetEnvironment().Update({ settings: { user: ""}, functions: { open: Func("AsUserOpener") } })
        runAsSetter := new SetUserFromUserConfig()
        contr.SubscribeCommandAboutToRun(CommandToSubscriber(runAsSetter, contr), {priority: this.PRIORITIES["userFromCommandConfig"]})
    }

    _DesktopsCompat(contr, desktopToUserMap) {
        if (desktopToUserMap != "") {
            desktopChanger := new ChangeDesktopFromUserConfig(desktopToUserMap)
            contr.SubscribeCommandAboutToRun(CommandToSubscriber(desktopChanger, contr), {priority: this.PRIORITIES["desktopFromCommandConfig"]})
            ; priority for `userSetter` must be higher (means running later) than for `desktopChanger`
            ; first change desktop, then change user based on that desktop
            userSetter := new SetUserFromDesktop(desktopToUserMap)
            contr.SubscribeCommandAboutToRun(CommandToSubscriber(userSetter, contr), {priority: this.PRIORITIES["userFromDesktop"]})
        }
    }

    _CommandsFileCompat(commandsFileExt) {
        commandsFileExt.RegisterCommand("ChangeUser", "Change user", ["User name"])
    }

    GetDesktopToUserMap() {
        return this._settings.desktopToUserMap
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
; 6) Run as different user (equivalent to `WithEnvironment({settings: {user: "user1"}}, command))
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
