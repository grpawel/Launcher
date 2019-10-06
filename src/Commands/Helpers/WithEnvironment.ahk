#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\RunDecorator.ahk


; Change environment and run command
; Small helper function.
; See also `Helpy` and `RunDecorator` docs.
WithEnvironment(environmentChange, wrapped) {
    seq := new Sequence([new ChangeEnvironment(environmentChange, "untilGuiClosed"), wrapped])
    return new RunDecorator(wrapped, seq)
}
