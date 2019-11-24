#Include %A_ScriptDir%\src\Commands\Command.ahk

; Remove command from given CommandSet.

; What this command does might not be obvious when commands are changed from other places.
; 1. First `Run` call removes command. It is saved for `Revert` command which brings it back.
; 2. Subsequent `Run` calls do nothing, if nothing else happened.
; 3. If user adds command from other place after `Run` call, next `Run` call removes this new command and remembers it for `Revert`.
;    Command removed previously is forgotten.
; 4. First `Revert` brings command back, subsequent `Revert` calls do nothing. Calling `Run` removes command again.
;    If after first `Revert` user removes or changes command from other place, next `Revert` calls still do nothing.
class RemoveCommand extends Command {
    __New(comset, key) {
        this._commandSet := comset
        this._key := key
        this._description := "Remove """ key """ from """ comset.GetDescription() """"
    }

    Run(contr, context) {
        existingCommand := this._commandSet.Get(this._key)
        if (existingCommand != "") {
            this._commandSet.Remove(this._key)
            this._removedCommand := existingCommand
        }
    }

    Revert(contr, context) {
        if (this._removedCommand != "") {
            this._commandSet.Add(this._key, this._removedCommand)
            this._removedCommand := ""
        }
    }
}
