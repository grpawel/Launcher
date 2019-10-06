#Include %A_ScriptDir%\src\Commands\Command.ahk

; Takes two commands, `decorated` and `runDecorator`.
; Passes all function calls to `decorated`,
; except `Run()`, which is passed to `runDecorator`.
;
; Why?
; This allows to take `CommandSet` object and transparently add some functionality like help,
; without losing access to other CommandSet values - tags, description etc.
; Following snippets are equivalent:
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
        result := com[methodName](params*)
        if (result == this._decorated) {
            ; Method returned `this`, which is decorated object.
            ; We have to instead return this decorator, in order for method chains to work correctly.
            ; Otherwise Helpy(new CommandSet()).SetDescription() would not work since SetDescription returns decorated object.
            result := this
        }
        return result
    }
}
