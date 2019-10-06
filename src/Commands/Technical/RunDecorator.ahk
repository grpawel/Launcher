#Include %A_ScriptDir%\src\Commands\Command.ahk

; Takes two commands, `decorated` and `runDecorator`.
; Passes all function calls to `decorated`,
; except `Run()`, which is passed to `runDecorator`.
;
; Why?
; This allows to take `CommandSet` object and transparently add some functionality like help,
; without losing any additional functionality - tags, description etc.
; Following snippets can be equivalent:
; (1)
; nested := new CommandSet()
; nested.AddTags(...)
; outer.AddCommand(Helpy(nested))
; (2)
; nested := Helpy(new CommandSet())
; nested.AddTags(...)
; outer.AddCommand(Helpy(nested))
class RunDecorator {
    __New(decorated, runDecorator) {
        this._decorated := decorated
        this._runDecorator := runDecorator
    }

    __Call(methodName, params*) {
        if (methodName == "Run") {
            com := this._runDecorator
        }
        else {
            com := this._decorated
        }
        return com[methodName](params*)
    }
}
