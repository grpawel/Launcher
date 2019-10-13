#Include %A_ScriptDir%\src\Commands\Command.ahk

; Forcefully destroy gui.
; Environment changes made with `WithEnvironment` might be reverted after running this command.
class DestroyGui extends Command {
    _description := "Destroy GUI"

    Run(controller, context) {
        controller.GetGui().Destroy()
    }
}
