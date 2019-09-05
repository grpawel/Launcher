#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class Reload extends Command {
    description := "Reload script"
    tags := ["technical"]

    Run(mainController) {
        Reload
    }
}