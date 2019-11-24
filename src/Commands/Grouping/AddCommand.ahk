#Include %A_ScriptDir%\src\Commands\Command.ahk

; Add command to given CommandSet.
; Replaces old command if one already exists with same key.
class AddCommand extends Command {
    __New(comset, key, com) {
        this._commandSet := comset
        this._key := key
        this._command := com
        this._description := "Add " key " command """ com.GetDescription() """ to """ comset.GetDescription() """"
    }

    Run(contr, context) {
        this._oldCommand := this._commandSet.Get(this._key)
        this._commandSet.Add(this._key, this._command)
    }

    Revert(contr, context) {
        if (this._oldCommand != "") {
            this._commandSet.Add(this._key, this._oldCommand)
        } else {
            this._commandSet.Remove(this._key)
        }
    }
}
