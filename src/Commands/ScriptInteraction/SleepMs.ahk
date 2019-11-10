#Include %A_ScriptDir%\src\Commands\Command.ahk

class SleepMs extends Command {
    __New(durationMs) {
        this._durationMs := durationMs
        this._description := "Sleep for " durationMs " ms"
    }

    Run(contr, context) {
        durationMs := GetValue(this._durationMs, contr, context)
        Sleep, durationMs
    }
}
