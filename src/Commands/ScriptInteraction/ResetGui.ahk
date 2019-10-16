#Include %A_ScriptDir%\src\Commands\Command.ahk

; Reset gui - remove all existing controls.
; Environment changes made with `WithEnvironment` should not be reverted after running this command.
class ResetGui extends Command {
    _description := "Destroy GUI"

    Run(controller, context) {
        controller.GetGui().Reset()
    }
}
