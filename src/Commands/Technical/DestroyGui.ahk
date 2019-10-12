#Include %A_ScriptDir%\src\Commands\Command.ahk

; Forcefully destroy gui.
class DestroyGui extends Command {
    _description := "Destroy GUI"

    Run(controller, context) {
        controller.GetGui().Destroy()
    }
}

WithGuiDestroyed(com) {
    seq := new Sequence([new DestroyGui(), com])
    return new RunDecorator(com, seq)
}
