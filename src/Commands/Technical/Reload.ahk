#Include %A_ScriptDir%\src\Commands\Command.ahk

class Reload extends Command {
    _description := "Reload script"

    __New() {
        this.AddTags(["technical"])
    }

    Run(mainController) {
        Reload
    }
}