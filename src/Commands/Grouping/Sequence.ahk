#Include %A_ScriptDir%\src\Commands\Command.ahk

; Runs sequence of commands one after another.
class Sequence extends Command {
    doesNeedGui {
        get {
            for i, com in this._commands.Clone() {
                anyCommandNeeds := anyCommandNeeds || com.doesNeedGui
            }
            return anyCommandNeeds
        }
    }

    __New(commands) {
        this._commands := commands
    }

    Run(mainController) {
        for i, com in this._commands {
            mainController.RunCommand(com, { caller: this })
        }
        return result
    }
}
