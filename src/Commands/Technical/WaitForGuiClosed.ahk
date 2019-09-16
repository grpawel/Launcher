#Include %A_ScriptDir%\src\Commands\Command.ahk

; Run given command after GUI has closed.
class WaitForGuiClosed extends Command {
    __New(command) {
        this._command := command
    }

    Run(mainController, context) {
        mainController.GetGui().SubscribeGuiClosing(this._OnGuiClosing.Bind(this, mainController, context), "once")
    }

    _OnGuiClosing(mainController, context) {
        command := this._command
        mainController.NotifyCommandAboutToRun(command)
        %command%(mainController, context)
    }
}