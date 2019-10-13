#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\MethodDecorator.ahk

; Block commands using predicate and fallbackMessage, then runs given command.
; Unblocks when gui is destroyed.
; For options see `CommandBlocker.AddBlocking()` docs.
; For explanation how it works, see also `WithHelpOpened` and `MethodDecorator` docs.
WithCommandsBlocked(predicate, wrapped, blockingOptions := "") {
    blocker := new BlockCommands(predicate, blockingOptions)
    unblocker := blocker.GetUnblockingCommand()
    seq := new Sequence([blocker, wrapped, new WaitForGuiDestroyed(unblocker)])
    return new MethodDecorator(wrapped, seq, ["Run"])
}
