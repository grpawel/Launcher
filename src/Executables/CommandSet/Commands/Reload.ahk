#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class Reload extends Command {
    description := "Reload script"

    Run() {
        Reload
    }
}