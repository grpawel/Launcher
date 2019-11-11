#Include %A_ScriptDir%\src\Commands\Command.ahk

; Run given command after GUI has destroyed.
class WaitForGuiDestroyed extends Command {
    __New(command) {
        this._command := command
        this._description := "Run " command.GetDescription() " after GUI is destroyed"
    }

    Run(controller, context) {
        controller.GetGui().SubscribeGuiDestroyed(this._OnGuiDestroyed.Bind(this, controller, context)
                                               , { duration: "once" })
    }

    _OnGuiDestroyed(controller, context) {
        controller.RunCommand(this._command, context)
    }
}
