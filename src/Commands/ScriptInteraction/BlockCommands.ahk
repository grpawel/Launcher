#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Commands\Technical\PlaceholderCommand.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\UnblockCommands.ahk

; Block every command for which `predicate` returns `true` or some string message.
; The message can be displayed to the user.
; If `predicate` returned true, `options.fallbackMessage` is used for the message.
; Running this command multiple times has no effect.

; For more options, see `src\CommandBlocker.AddBlocking()` method.
class BlockCommands extends Command {
    __New(predicate, blockerOptions = "") {
        this._predicate := predicate
        this._blockerOptions := blockerOptions
    }

    Run(contr) {
        this._EnsureBlockerNameIsSet()
        contr.GetBlocker().AddBlocking(this._predicate, this._blockerOptions)
    }

    Revert(contr, context) {
        this._EnsureBlockerNameIsSet()
        new UnblockCommands(this._blockerOptions.name).Run(contr, context)
    }

    _EnsureBlockerNameIsSet() {
        ; Add blocker only once by using same name
        if (this._blockerOptions.name == "") {
            this._blockerOptions.name := RandomString(6)
        }
    }
}
