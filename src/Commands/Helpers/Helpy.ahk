#Include %A_ScriptDir%\src\Commands\Grouping\Sequence.ahk
#Include %A_ScriptDir%\src\Commands\Technical\RunDecorator.ahk

; Show help with CommandSet by default.
; Transparently wraps given CommandSet with help.
; Calls to returned object (like .AddTags()) are passed to CommandSet given in argument,
; so Helpy can be called anywhere.
; See also `RunDecorator` docs.
; Example: 
; films := Helpy(_.CommandSet()).SetDescription( ...)
; something["film"] := Helpy(films)

Helpy(comSet) {
    seq := new Sequence([comSet, new Help(comSet)])
    return new RunDecorator(comSet, seq)
}
