#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Commands\Technical\PlaceholderCommand.ahk

; Block every command for which `predicate` returns `true` or some string message.
; The message can be displayed to the user.
; If `predicate` returned true, `options.fallbackMessage` is used for the message.
; Running this command multiple times has no effect.
; For more options, see `src\CommandBlocker.AddBlocking()` method.
class BlockCommands extends Command {
    __New(predicate, blockerOptions = "") {
        this._predicate := predicate
        this._blockerOptions := blockerOptions
        
        this._unblockingPlaceholder := new PlaceholderCommand()
    }

    Run(contr) {
        ; Add blocker only once by using same name
        if (this._blockerOptions.name == "") {
            this._blockerOptions.name := RandomString(6)
        }
        blocker := contr.GetBlocker().AddBlocking(this._predicate, this._blockerOptions)
        unblocker := new UnblockCommands(blocker)
        this._unblockingPlaceholder.SetPlaceholdedCommand(unblocker)
    }

    ; Run returned command to unblock.
    GetUnblockingCommand() {
        return this._unblockingPlaceholder
    }
}

class UnblockCommands extends Command {
    __New(blockerName) {
        this._blockerName := blockerName
    }

    Run(contr) {
        contr.GetBlocker().Unblock(this._blockerName)
    }
}
