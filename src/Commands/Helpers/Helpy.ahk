#Include %A_ScriptDir%\src\Commands\Command.ahk

; Show help with CommandSet by default.
; Small helper function.
; Uses description and tags from given CommandSet.
; 
; Example: 
; films := _.CommandSet().SetDescription( ...
; something["film"] := Helpy(films)
Helpy(wrapped) {
    return new Sequence([wrapped, new Help(wrapped)])
        .SetDescription(wrapped.GetDescription())
        .AddTags(wrapped.GetTags())
}
