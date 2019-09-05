#Include %A_ScriptDir%\src\Commands\Command.ahk

class Reload extends Command {
    description := "Reload script"
    tags := ["technical"]

    Run(mainController) {
        Reload
    }
}