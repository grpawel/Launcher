#Include %A_ScriptDir%\src\Commands\Helpers\WithCommandThenReverted.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\UnblockCommands.ahk

; Disable some rule for some time, then run command.
; See `CommandBlocker.Unblock()` method docs.
; For options see `WithCommandThenReverted`.
; 
; If `wrapped` command would be blocked by the rule we want to disable,
; command returned from this function will still be blocked.
; This happens because returned command passes all method calls to `wrapped`,
; causing no difference rule to block it.

; To prevent this, set `options.wrapper` to "opaque".
; This will change command's description, tags etc., but there is no other possibility
; as the rule could block using those description or tags.
; Alternatively wrap returned or `wrapped` command in additional `Sequence`.
WithBlockerRuleDisabled(blockerRuleName, wrapped, options = "") {
    unblocker := new UnblockCommands(blockerRuleName)
    return WithCommandThenReverted(unblocker, wrapped, options)
}
