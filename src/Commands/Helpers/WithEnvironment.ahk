#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\MethodDecorator.ahk


; Change environment and run command
; Small helper function.
; See also `WithHelpOpened` and `MethodDecorator` docs.
WithEnvironment(environmentChange, wrapped) {
    seq := new Sequence([new ChangeEnvironment(environmentChange, "untilGuiClosed"), wrapped])
    return new MethodDecorator(wrapped, seq, ["Run"])
}
