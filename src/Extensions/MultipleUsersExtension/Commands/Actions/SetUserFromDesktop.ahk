#Include %A_ScriptDir%\src\Commands\Command.ahk

; Changes user in environment based on current desktop.
; Intended to be subscribed to GUI opening,
; so the user can be changed using another command.
;
; Takes object mapping desktop to username, eg.:
; { "1": "games", "2": "work" }
; For desktop number not in map user is an empty string.
;
; Requires DesktopsExtension to be active.

class SetUserFromDesktop extends Command {
    __New(desktopToUserMap) {
        this._desktopToUserMap := desktopToUserMap
    }

    Run(controller, context="") {
        desktop := controller.GetDesktop()
        newUser := this._desktopToUserMap[desktop]
        oldUser := controller.GetEnvironment()["user"]
        if (newUser != oldUser) {
            envChanger := new ChangeEnvironment({ user: newUser})
            ; We cannot use controller.RunCommand() here, 
            ; because we could be stuck in a loop.
            envChanger.Run(controller, { caller: this })
        }
    }
}
