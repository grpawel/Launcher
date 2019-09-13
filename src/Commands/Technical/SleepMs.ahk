#Include %A_ScriptDir%\src\Commands\Command.ahk

class SleepMs extends Command {
    tags := ["technical"]

    __New(durationMs) {
        this._durationMs := durationMs
        this.description := "Sleep for " durationMs " ms"
    }

    Run(mainController) {
        Sleep % this._durationMs
    }
}