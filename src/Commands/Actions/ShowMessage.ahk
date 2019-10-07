#Include %A_ScriptDir%\src\Commands\Command.ahk

class ShowMessage extends Command {
    __New(message) {
        this._message := message
        this._description := "Show message """ message """"
    }

    Run(controller) {
        controller.GetGui().DisableAll()
        controller.GetGui().AddText({ text: this._message })

    }

    DoesNeedGui() {
        return true
    }
}
