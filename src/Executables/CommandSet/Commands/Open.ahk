#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class Open extends Command {
    __New(toRun) {
        this._toRun := toRun
    }
    Run() {
        run, % this._toRun
    }

    GetTitle() {
        return "Open " this._toRun
    }
}