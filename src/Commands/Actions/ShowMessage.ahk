#Include %A_ScriptDir%\src\Commands\Command.ahk

class ShowMessage extends Command {
    __New(message) {
        this._message := message
        this._description := "Show message """ message """"
    }

    Run(mainController) {
        mainController.GetGui().DisableAll()
        mainController.GetGui().AddText({ text: this._message })

    }

    DoesNeedGui() {
        return true
    }
}
