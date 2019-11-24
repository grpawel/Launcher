#Include %A_ScriptDir%\src\Commands\Command.ahk

; Takes two objects, `obj` and `decorator`.
; Passes all function calls to `obj`,
; except methods given in `decoratedMethodNames` which are passed to `decorator`.
;
; Why?
; This allows to take `CommandSet` object and transparently add some functionality like help,
; without losing access to other CommandSet methods - tags, description etc.
; Following snippets are equivalent:
; (1)
; nested := new CommandSet()
; nested.AddTags(...)
; commands.AddCommand(WithHelpOpened(nested))
; (2)
; nested := WithHelpOpened(new CommandSet())
; nested.AddTags(...)
; commands.AddCommand(nested)
class MethodDecorator {
    __New(obj, decorator, decoratedMethodNames) {
        this._obj := obj
        this._decorator := decorator
        this._decoratedMethodNames := decoratedMethodNames
    }

    __Call(methodName, params*) {
        if (ArrayContains(this._decoratedMethodNames, methodName)) {
            obj := this._decorator
        }
        else {
            obj := this._obj
        }
        result := obj[methodName](params*)
        if (result == this._obj && methodName != "_NewEnum") {
            ; Method returned `this`, which is decorated object.
            ; We have to instead return this decorator, in order for method chains to work correctly.
            ; Otherwise `WithHelpOpened(new CommandSet()).SetDescription()`
            ; would return `CommandSet` object and not `MethodDecorator`.
            result := this
        }
        return result
    }
}
