#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\MethodDecorator.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\RevertCommand.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\WaitForGuiDestroyed.ahk

; Change environment and run command.
; Returns command that acts as it it was `wrapped` command.
; See also `WithHelpOpened` and `MethodDecorator` docs.
; 
; Options:
; mode: "permanent" - changes are permanent until the script is reloaded
; mode: "untilGuiDestroyed" (default) - changes are reverted when GUI is destroyed
;
; For explanation how it works, see also `WithHelpOpened` and `MethodDecorator` docs.
WithEnvironment(environmentChange, wrapped, options = "") {
    static V := new ValidatorFactory()
    static VAL := V.Object({ "mode": V.OneOf(["permanent", "untilGuiDestroyed"]) }
                        , { ignoreMissing: false, noOtherKeys: true })
    static DEFAULT_OPTIONS := { mode: "untilGuiDestroyed" }
    options := MergeArrays(DEFAULT_OPTIONS, options)
    VAL.ValidateAndShow(options)
    
    changeCommand := new ChangeEnvironment(environmentChange)
    if (options.mode == "permanent") {
        seq := new Sequence([ changeCommand, wrapped ])
    } else if (options.mode == "untilGuiDestroyed") {
        seq := new Sequence([ changeCommand, wrapped, new WaitForGuiDestroyed(new RevertCommand(changeCommand)) ])
    }
    return new MethodDecorator(wrapped, seq, ["Run"])
}