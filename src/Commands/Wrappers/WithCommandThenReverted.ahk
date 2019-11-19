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
; mode: "forCommand" - reverts when `wrapped` command returns from its `Run()` method.
;                      Works with simple commands (`Open`),
;                      does not work when `wrapped` does something outside `Run()` method,
;                      eg. `CommandSet` or any `Sequence` containing `CommandSet`.
; mode: "untilGuiDestroyed" (default) - command is reverted when GUI is destroyed.
; mode: "permanent" - command is not reverted, its actions are permanent until something else overrides them or script is reloaded.
; wrapper: "transparent" (default) - returned command passes all method calls to `wrapped`,
;                                    so in most other places behaves like `wrapped`.
; wrapper: "opaque" - returns new command. Description, tags etc. must be set again.
;
; For explanation how it works, see also `WithHelpOpened` and `MethodDecorator` docs.
WithCommandThenReverted(commandToRevert, wrapped, options = "") {
    static V := new ValidatorFactory()
    static VAL := V.Object({ "mode": V.OneOf(["forCommand", "permanent", "untilGuiDestroyed"])
                           , "wrapper": V.OneOf(["transparent", "opaque"]) })
    static DEFAULT_OPTIONS := { mode: "untilGuiDestroyed"
                              , wrapper: "transparent" }
    options := MergeArrays(DEFAULT_OPTIONS, options)
    VAL.ValidateAndShow(options)
    
    if (options.mode == "forCommand") {
        seq := new Sequence([ commandToRevert, wrapped, new RevertCommand(commandToRevert) ])
    } else if (options.mode == "untilGuiDestroyed") {
        seq := new Sequence([ commandToRevert, wrapped, new WaitForGuiDestroyed(new RevertCommand(commandToRevert)) ])
    } else if (options.mode == "permanent") {
        seq := new Sequence([ commandToRevert, wrapped ])
    } 
    if (options.wrapper == "transparent") {
        return new MethodDecorator(wrapped, seq, ["Run"])
    } else {
        return seq
    }
}
