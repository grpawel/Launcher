#Include %A_ScriptDir%\src\Commands\Command.ahk

; Use specific controller instead of one calling
class UseController extends Command {
    __New(fixedController, com) {
        this._fixedController := fixedController
        this._command := com
    }

    Run(contr, context) {
        this._command.Run(this._fixedController, context)
    }

    Revert(contr, context) {
        this._command.Revert(this._fixedController, context)
    }
}
