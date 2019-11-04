#Include %A_ScriptDir%\src\Commands\Command.ahk

class RevertCommand extends Command {
    __New(com) {
        this._command := com
        this._description := "Revert """ com.GetDescription() """"
    }

    Run(contr, context) {
        this._command.Revert(contr, context)
    }
}
