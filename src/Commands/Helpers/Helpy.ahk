#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\RunDecorator.ahk

; Show help with CommandSet by default.
; Transparently wraps given CommandSet with help.
; Calls to returned object (like .AddTags()) are passed to CommandSet given in argument,
; so Helpy can be called anywhere.
; See also `RunDecorator` docs.
; Example: 
; films := Helpy(_.CommandSet().SetDescription(...))
; something["film"] := Helpy(films)
; 
; Be careful where to put closing parenthesis:
; `Helpy(_.CommandSet() ) .SetDescription(...)` would not work correctly, because `SetDescription` returns inner `CommandSet`.
; Either `Helpy()` must embrace whole expression, or .SetDescription(...) has to be called later, in separate line.

Helpy(comSet) {
    seq := new Sequence([comSet, new Help(comSet)])
    return new RunDecorator(comSet, seq)
}
