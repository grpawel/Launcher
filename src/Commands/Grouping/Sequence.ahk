#Include %A_ScriptDir%\src\Commands\Command.ahk

; Runs sequence of commands one after another.
class Sequence extends Command {
    doesNeedGui {
        get {
            for i, command in this._commands {
                anyCommandNeeds := anyCommandNeeds || command.doesNeedGui
            }
            return anyCommandNeeds
        }
    }

    __New(commands) {
        this._commands := commands
    }

    Run(mainController) {
        for index, command in this._commands {
            %command%(mainController, this)
        }
        return result
    }
}