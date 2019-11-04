#Include %A_ScriptDir%\src\Commands\ScriptInteraction\ChangeEnvironment.ahk
#Include %A_ScriptDir%\src\Commands\Helpers\WithCommandThenReverted.ahk

; Change environment for some time and run command.
; For options see `WithCommandThenReverted` docs.
WithEnvironment(environmentChange, wrapped, options = "") {
    changeCommand := new ChangeEnvironment(environmentChange)
    return WithCommandThenReverted(changeCommand, wrapped, options)
}
