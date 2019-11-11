#Include %A_ScriptDir%\src\Commands\Command.ahk

class UnblockCommands extends Command {
    __New(blockerRuleName) {
        this._blockerRuleName := blockerRuleName
        this._description := "Unblock some commands (rule " blockerRuleName ")"
    }

    Run(contr) {
        contr.GetBlocker().DisableRule(this._blockerRuleName)
    }

    Revert(contr) {
        contr.GetBlocker().AddRule(this._blockerRuleName)
    }
}