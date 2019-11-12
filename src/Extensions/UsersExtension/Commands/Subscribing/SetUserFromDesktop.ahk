#Include %A_ScriptDir%\src\Commands\Command.ahk

; Changes user setting in environment based on current desktop.
; Intended to be subscribed to GUI opening,
; so the user can be changed using another command.
; 
; Be careful, different controllers might have different configurations so results may vary.
; If desktop is not included in mapping the user is set to an empty string.
;
; Requires DesktopsExtension to be active.
class SetUserFromDesktop extends Command {
    _description := "Set user from desktop"

    Run(contr, context="") {
        desktop := GetDesktopFunction()
        desktopToUserMap := contr.GetExtensionManager().GetExtension("users").GetDesktopToUserMap()
        newUser := desktopToUserMap[desktop]
        oldUser := contr.GetEnvironment().GetSetting("user")
        if (newUser != oldUser) {
            envChanger := new ChangeEnvironment({ settings: { user: newUser } })
            contr.RunCommandWithoutEvents(envChanger, { caller: this })
        }
    }
}
