#Include %A_ScriptDir%\src\Commands\Command.ahk

class SleepMs extends Command {
    __New(durationMs) {
        this._durationMs := durationMs
        this._description := "Sleep for " durationMs " ms"
        this.AddTags(["technical"])
    }

    Run(controller) {
        Sleep % this._durationMs
    }
}
