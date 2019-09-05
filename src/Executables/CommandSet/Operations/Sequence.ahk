#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

; Runs sequence of commands one after another.
class Sequence extends Command {
    __New(commands) {
        this._commands := commands
    }

    Run(executableService) {
        result := true
        for index, command in this._commands {
            singleResult := %command%(executableService)
            result := result && singleResult
        }
        return result
    }
}