#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class Open extends Command {
    tags := ["hasPath"]

    __New(toRun) {
        this._toRun := toRun
        this.description := "Open " this._toRun
    }

    Run(environment) {
        environment.defaultOpener.Open(this._toRun)
    }
}