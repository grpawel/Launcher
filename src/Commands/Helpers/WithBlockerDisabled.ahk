#Include %A_ScriptDir%\src\Commands\Helpers\WithCommandThenReverted.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\UnblockCommands.ahk

; Unblock some blocker for some time, run command.
; See `CommandBlocker.Unblock()` method docs.
; For options see `WithCommandThenReverted`.
WithBlockerDisabled(blockerName, wrapped, options = "") {
    unblocker := new UnblockCommands(blockerName)
    return WithCommandThenReverted(unblocker, wrapped, options)
}
