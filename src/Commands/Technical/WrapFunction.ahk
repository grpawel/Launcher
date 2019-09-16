#Include %A_ScriptDir%\src\Commands\Command.ahk

; Wrapper for making commands from functions.
; Allows them to have description, tags etc.
class WrapFunction extends Command {
    __New(function) {
        this._function := function
    }

    Run(mainController, context) {
        parametersNumber := IsFunc(this._function) - 1
        additionalParameters := []
        for i in range(0, parametersNumber - 2) {
            additionalParameters.Push("")
        }
        this._function.Call(mainController, context, additionalParameters*)
    }
}