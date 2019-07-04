#Include %A_ScriptDir%\src\Executables\Commands\Command.ahk

class Open extends Command {
    __New(toRun) {
        this._toRun := toRun
    }
    Run() {
        run, % this._toRun
    }
}