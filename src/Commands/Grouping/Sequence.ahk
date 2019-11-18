#Include %A_ScriptDir%\src\Commands\Command.ahk

; Runs sequence of commands one after another.
class Sequence extends Command {
    __New(commands) {
        this._commands := commands
        this.AddTags(["composite"])
    }

    Run(controller) {
        for i, com in this._commands {
            controller.RunCommand(com, { caller: this })
        }
        return result
    }

    GetCommands() {
        return this._commands
    }

    DoesNeedGui() {
        for i, com in this._commands.Clone() {
                anyCommandNeeds := anyCommandNeeds || com.DoesNeedGui()
        }
            return anyCommandNeeds
    }
}
