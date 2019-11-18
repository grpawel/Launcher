#Include %A_ScriptDir%\src\Commands\Command.ahk

; Runs sequence of commands one after another.
class Sequence extends Command {
    __New(commands) {
        this._commands := commands
        this.AddTags(["composite"])
    }

    Run(contr, context) {
        for i, com in this._commands {
            contr.RunCommand(com, MergeArrays(context, { caller: this }))
        }
        return result
    }

    GetCommands() {
        return this._commands
    }

    DoesNeedGui() {
        for i, com in this._commands.Clone() {
            if (com.DoesNeedGui()) {
                return true
            }
        }
        return false
    }
}
