#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Commands\Technical\PlaceholderCommand.ahk

; Block every command for which `predicate` returns `true` or some string message.
; The message can be displayed to the user.
; If `predicate` returned true, `options.fallbackMessage` is used for the message.
; 
; For more options, see `src\CommandBlocker.AddBlocking()` method.
class BlockCommands extends Command {
    __New(predicate, options = "") {
        this._predicate := predicate
        this._blockerOptions := options
        this._unblockingPlaceholder := new PlaceholderCommand()
    }

    Run(contr) {
        blocker := contr.GetBlocker().AddBlocking(this._predicate, this._blockerOptions)
        unblocker := new UnblockCommands(blocker)
        this._unblockingPlaceholder.SetPlaceholdedCommand(unblocker)
    }

    ; Run returned command to unblock.
    ; Currently there is no other way to unblock.
    GetUnblockingCommand() {
        return this._unblockingPlaceholder
    }
}

class UnblockCommands extends Command {
    __New(blocker) {
        this._blocker := blocker
    }

    Run(contr) {
        contr.GetBlocker().Unblock(this._blocker)
    }
}
