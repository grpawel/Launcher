#Include %A_ScriptDir%\src\Commands\Command.ahk

; Change user setting in environment.
; These are equivalent:
/*
new ChangeUser("user0")
new ChangeEnvironment({ settings: { user: "user0" } })
*/
class ChangeUser extends Command {
    __New(user) {
        this._changeCommand := new ChangeEnvironment({ settings: { user: user } })
        this._description := "Change user to " user
    }

    Run(contr, context) {
        contr.RunCommand(this._changeCommand)
    }

    Revert(contr, context) {
        this._changeCommand.Revert(contr, context)
    }
}
