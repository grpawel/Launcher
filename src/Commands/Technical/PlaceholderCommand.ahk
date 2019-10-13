#Include %A_ScriptDir%\src\Commands\Command.ahk

; For situations where we want to run some command, but we do not have it yet.
; Passes all method calls to underlying object.
class PlaceholderCommand extends Command {
    __Call(method, params*) {
        ; Name is somewhat weird to minimize risk of name clashes.
        if (method == "SetPlaceholdedCommand") {
            this._command := params[1]
        } else {
            com := this._command
            return com[method](params*)
        }
    }
}
