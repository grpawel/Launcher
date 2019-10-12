#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\RunDecorator.ahk

; Show help with `CommandSet` by default.
; Example: 
/*
films := _.CommandSet().SetDescription(...)
something["film"] := WithHelpOpened(films)
*/
; Transparently wraps given `CommandSet` returning other object,
; that passes all method calls to underlying `CommandSet`.
; This allows `WithHelpOpened` to be called anywhere.
; See also `RunDecorator` docs.
; In other words, closing parenthesis can be put anywhere:
; `WithHelpOpened(_.CommandSet().SetDescription(...))` and 
; `WithHelpOpened(_.CommandSet()).SetDescription(...)` are equivalent.
; `WithHelpOpened` does not interfere with using `Help` command to close help.
WithHelpOpened(comSet) {
    seq := new Sequence([comSet, new Help(comSet)])
    return new RunDecorator(comSet, seq)
}
