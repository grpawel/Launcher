#Include %A_ScriptDir%\src\Commands\Command.ahk

; Reset gui - remove all existing controls.
; Does not destroy GUI - `WithCommandThenReverted` won't revert with "untilGuiDestroyed" setting.
class ResetGui extends Command {
    _description := "Reset GUI"

    Run(contr, context) {
        contr.GetGui().Reset()
    }

    Revert(contr) {
        contr.GetGui().Show()
    }
}
