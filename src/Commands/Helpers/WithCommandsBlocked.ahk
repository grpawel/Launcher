#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\MethodDecorator.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\RevertCommand.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\WaitForGuiDestroyed.ahk

; Block commands using `predicate` and fallbackMessage, then runs given command.
; See `CommandBlocker.AddBlocking()` docs.
;
; Options:
; wrapper.mode: "permanent" - changes are permanent until the script is reloaded
; wrapper.mode: "untilGuiDestroyed" (default) - changes are reverted when GUI is destroyed.
; blocker:... - options passed to `CommandBlocker.AddBlocking()`
; 
; For explanation how it works, see also `WithHelpOpened` and `MethodDecorator` docs.
WithCommandsBlocked(predicate, wrapped, options = "") {
    ; prevent always creating new blocker
    if (options.blocker.name == "") {
        if (options.blocker == "") {
            options.blocker := {}
        }
        options.blocker.name := RandomString(6)
    }

    static V := new ValidatorFactory()
    static VAL := V.Object({ "wrapper": V.Object({ "mode": V.OneOf(["permanent", "untilGuiDestroyed"]) }
                                               , { ignoreMissing: false, noOtherKeys: true })
                           , "blocker": V.AlwaysTrue() }
                          , { ignoreMissing: true, noOtherKeys: true })
    static DEFAULT_OPTIONS := { wrapper: { mode: "untilGuiDestroyed" } }
    options := MergeArrays(DEFAULT_OPTIONS, options)
    VAL.ValidateAndShow(options)
    
    blockCommand := new BlockCommands(predicate, options.blocker)
    if (options.wrapper.mode == "permanent") {
        seq := new Sequence([ blockCommand, wrapped ])
    } else if (options.wrapper.mode == "untilGuiDestroyed") {
        seq := new Sequence([ blockCommand, wrapped, new WaitForGuiDestroyed(new RevertCommand(blockCommand)) ])
    }
    return new MethodDecorator(wrapped, seq, ["Run"])
}
