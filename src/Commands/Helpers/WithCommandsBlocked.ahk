#Include %A_ScriptDir%\src\Commands\ScriptInteraction\BlockCommands.ahk
#Include %A_ScriptDir%\src\Commands\Helpers\WithCommandThenReverted.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

; Block commands using `predicate`, then run given command.
; See `CommandBlocker.AddRule()` docs.
;
; Options:
; wrapper:... - options passed to `WithCommandThenReverted`.
; blocker:... - options passed to `CommandBlocker.AddRule()`.
WithCommandsBlocked(predicate, wrapped, options = "") {
    ; prevent always creating new blocker rule
    if (options.blocker.name == "") {
        if (options.blocker == "") {
            options.blocker := {}
        }
        options.blocker.name := RandomString(6)
    }
    blockCommand := new BlockCommands(predicate, options.blocker)
    return WithCommandThenReverted(blockCommand, wrapped, options.wrapper)
}
