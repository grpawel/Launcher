#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Commands\Technical\PlaceholderCommand.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\UnblockCommands.ahk

; Block every command for which `predicate` returns `true` or some string message.
; The message can be displayed to the user.
; If `predicate` returned true, `options.fallbackMessage` is used for the message.
; Running this command multiple times has no effect.

; For more options, see `src\CommandBlocker.AddRule()` method.
class BlockCommands extends Command {
    __New(predicate, blockerOptions = "") {
        this._predicate := predicate
        this._blockerOptions := EnsureIsObject(blockerOptions)
    }

    Run(contr) {
        this._EnsureRuleNameIsSet()
        contr.GetBlocker().AddRule(this._predicate, this._blockerOptions)
    }

    Revert(contr, context) {
        this._EnsureRuleNameIsSet()
        new UnblockCommands(this._blockerOptions.name).Run(contr, context)
    }

    _EnsureRuleNameIsSet() {
        ; Add blocker only once by using same name
        if (this._blockerOptions.name == "") {
            this._blockerOptions.name := RandomString(6)
        }
    }
}
