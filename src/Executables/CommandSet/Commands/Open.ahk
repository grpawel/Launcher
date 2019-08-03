#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class Open extends Command {
    __New(toRun) {
        this._toRun := toRun
        this.description := "Open " this._toRun
    }

    Run() {
        run, % this._toRun
    }
}