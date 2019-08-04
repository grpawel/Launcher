#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class ChangeEnvironment extends Command {
    __New(changes) {
        this._changes := changes
    }

    Run(environment, executableService) {
        executableService.UpdateEnvironment(this._changes)
    }
}