#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\MethodDecorator.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\RevertCommand.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\WaitForGuiDestroyed.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk

; Run one command (`commandToRevert`), run second command (`wrapped`), and revert first one.
; Returned command acts as it is `wrapped` command.
; `commandToRevert` must have `Revert()` method.
; 
; Options:
; mode: "untilGuiDestroyed" (default) - command is reverted when GUI is destroyed.
; mode: "permanent" - command is not reverted, its actions are permanent until something else overrides them or script is reloaded.
;
; For explanation how it works, see also `WithHelpOpened` and `MethodDecorator` docs.
WithCommandThenReverted(commandToRevert, wrapped, options = "") {
    static V := new ValidatorFactory()
    static VAL := V.Object({ "mode": V.OneOf(["forCommand", "permanent", "untilGuiDestroyed"]) }
                        , { ignoreMissing: false, noOtherKeys: true })
    static DEFAULT_OPTIONS := { mode: "untilGuiDestroyed" }
    options := MergeArrays(DEFAULT_OPTIONS, options)
    VAL.ValidateAndShow(options)
    
    if (options.mode == "untilGuiDestroyed") {
        seq := new Sequence([ commandToRevert, wrapped, new WaitForGuiDestroyed(new RevertCommand(commandToRevert)) ])
    } else if (options.mode == "permanent") {
        seq := new Sequence([ commandToRevert, wrapped ])
    } 
    return new MethodDecorator(seq, wrapped, ["Run"])
}
