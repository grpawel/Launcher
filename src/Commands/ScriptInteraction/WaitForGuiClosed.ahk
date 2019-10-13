#Include %A_ScriptDir%\src\Commands\Command.ahk

; Run given command after GUI has closed.
class WaitForGuiClosed extends Command {
    __New(command) {
        this._command := command
    }

    Run(controller, context) {
        controller.GetGui().SubscribeGuiClosing(this._OnGuiClosing.Bind(this, controller, context)
                                               , { duration: "once" })
    }

    _OnGuiClosing(controller, context) {
        controller.RunCommand(this._command, context)
    }
}
