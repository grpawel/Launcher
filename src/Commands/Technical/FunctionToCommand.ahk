#Include %A_ScriptDir%\src\Commands\Command.ahk

; Wrapper for making commands from functions.
; Allows them to have description, tags etc.
class FunctionToCommand extends Command {
    __New(function) {
        this._function := function
    }

    Run(controller, context) {
        parametersNumber := IsFunc(this._function) - 1
        additionalParameters := []
        for i in range(0, parametersNumber - 2) {
            additionalParameters.Push("")
        }
        ; If a function takes more parameters than two, it would not be called.
        ; See https://www.autohotkey.com/docs/Functions.htm#DynCall
        this._function.Call(controller, context, additionalParameters*)
    }
}
