#Include %A_ScriptDir%\src\Commands\Command.ahk

; Runs sequence of commands one after another.
class Sequence extends Command {
    __New(commands) {
        this._commands := commands
    }

    Run(mainController) {
        result := true
        for index, command in this._commands {
            singleResult := %command%(mainController)
            result := result && singleResult
        }
        return result
    }
}