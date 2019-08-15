#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class Open extends Command {
    tags := ["hasPath"]

    __New(toRun) {
        this._toRun := toRun
        this.description := "Open " this._toRun
    }

    Run(environment, executableService) {
        environment.Open.Default(this._toRun, environment)
    }
}