#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\MethodDecorator.ahk

; Unblock some blocker, run command, then block again.
WithBlockerDisabled(blockerName, wrapped) {
    unblocker := new UnblockCommands(blockerName)
    blocker := new BlockCommands(blockerName)
    seq := new Sequence([unblocker, wrapped, new WaitForGuiDestroyed(blocker)])
    return new MethodDecorator(wrapped, seq, ["Run"])
}
