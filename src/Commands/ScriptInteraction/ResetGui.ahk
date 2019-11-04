#Include %A_ScriptDir%\src\Commands\Command.ahk

; Reset gui - remove all existing controls.
; Does not destroy GUI - `WithCommandThenReverted` won't revert with "untilGuiDestroyed" setting.
class ResetGui extends Command {
    _description := "Destroy GUI"

    Run(controller, context) {
        controller.GetGui().Reset()
    }
}
