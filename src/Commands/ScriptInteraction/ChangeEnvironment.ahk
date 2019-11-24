#Include %A_ScriptDir%\src\Commands\Command.ahk

; Change some keys in environment.
; Those changes can be reverted to old values by calling `Revert` method (eg. using `RevertCommand`).
; Example:
/*
comset.Add("fire", new ChangeEnvironment({settings: { browser: "firefox" }}))
comset.Add("chr", new ChangeEnvironment({settings: { browser: "chrome" }}))
*/

; Reverting changes can have unexpected results when the environment is changed in the meantime.
; If this commands adds new keys to environment, this cannot be currently reverted.

; In complicated setups better do not reuse the same command object in multiple places when using `Revert` method.
; Instead duplicate the command.
class ChangeEnvironment extends Command {
    _description := "Change environment"

    __New(changes) {
        this._changes := changes
    }

    Run(contr, context) {
        changes := GetValue(this._changes, contr, context)
        this._oldValues := contr.GetEnvironment().Update(changes)
    }

    Revert(contr) {
        contr.GetEnvironment().Update(this._oldValues)
    }
}
