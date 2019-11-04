#Include %A_ScriptDir%\src\Commands\Helpers\WithCommandThenReverted.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\UnblockCommands.ahk

; Disable some rule for some time, run command.
; See `CommandBlocker.Unblock()` method docs.
; For options see `WithCommandThenReverted`.
WithBlockerRuleDisabled(blockerRuleName, wrapped, options = "") {
    unblocker := new UnblockCommands(blockerRuleName)
    return WithCommandThenReverted(unblocker, wrapped, options)
}
