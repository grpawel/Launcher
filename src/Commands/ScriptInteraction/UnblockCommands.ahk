#Include %A_ScriptDir%\src\Commands\Command.ahk

class UnblockCommands extends Command {
    __New(blockerName) {
        this._blockerName := blockerName
    }

    Run(contr) {
        contr.GetBlocker().Unblock(this._blockerName)
    }

    Revert(contr) {
        contr.GetBlocker().AddBlocking(this._blockerName)
    }
}