#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\MethodDecorator.ahk

; Show help with `CommandSet` by default.
; Example: 
/*
films := _.CommandSet().SetDescription(...)
something["film"] := WithHelp(films)
*/
; Transparently wraps given `CommandSet` returning other object,
; that passes all method calls to underlying `CommandSet`.
; This allows `WithHelp` to be called anywhere.
; See also `MethodDecorator` docs.
; In other words, closing parenthesis can be put anywhere:
; `WithHelp(_.CommandSet().SetDescription(...))` and 
; `WithHelp(_.CommandSet()).SetDescription(...)` are equivalent.
; `WithHelp` does not interfere with using `Help` command to close help.
WithHelp(comSet) {
    seq := new Sequence([comSet, new Help(comSet)])
    return new MethodDecorator(comSet, seq, ["Run"])
}
