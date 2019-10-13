#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\ChangeDesktopFromUserConfig.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Actions\SetUserFromDesktop.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Commands\Blockers\IsUserAllowed.ahk
#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\Environment\Openers\AsUserOpener.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk
#Include %A_ScriptDir%\src\Utils\CommandUtils.ahk

extensionManager.RegisterExtension(new MultipleUsersExtension())

class MultipleUsersExtension {
    name := "multipleUsers"

    __New() {
        Command.UserConfig := Func("_Command_UserConfig")
        Command.GetUserConfig := Func("_Command_GetUserConfig")
    }

    Attach(controller, availableExtensions, settings = "") {
        desktopToUserMap := settings.desktopToUserMap
        if (availableExtensions.HasKey("desktops")) {
            this._DesktopsCompat(controller, desktopToUserMap)
        }
        controller.GetBlocker().AddBlocking(Func("MultipleUsers_IsUserAllowed"), { name: "isUserAllowed" })

        controller.UpdateEnvironment(MergeArrays({ user: ""}, AsUserOpener()))
    }

    _DesktopsCompat(controller, desktopToUserMap) {
        if (desktopToUserMap != "") {
            desktopChanger := new ChangeDesktopFromUserConfig(desktopToUserMap)
            controller.SubscribeCommandAboutToRun(BindControllerToCommand(desktopChanger, controller), {priority: 10})
            ; priority for `userSetter` must be higher (means running later) than for `desktopChanger`
            ; first change desktop, then change user based on that desktop
            userSetter := new SetUserFromDesktop(desktopToUserMap)
            controller.SubscribeCommandAboutToRun(BindControllerToCommand(userSetter, controller), {priority: 20})
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
; 6) A combination of above. Same user in multiple options can cause unexpected results.
_Command_UserConfig(this, config) {
    static V := new ValidatorFactory()
    static VAL := V.Object( { "blacklist": V.Or([V.Equal("all"), V.ObjectEachValue(V.String())])
                            , "whitelist": V.Or([V.Equal("all"), V.ObjectEachValue(V.String())])
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

_Command_GetUserConfig(this) {
    return this._userConfig
}
