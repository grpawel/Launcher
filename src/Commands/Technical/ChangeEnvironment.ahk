#Include %A_ScriptDir%\src\Commands\Command.ahk

class ChangeEnvironment extends Command {

    ; Nothing is changed anywhere until this command is run.
    ; Possible modes:
    ; permanent - changes are permanent until the script is reloaded
    ; untilGuiClosed - changes are reverted when GUI is closed
    ; Reversal of changes can have unexpected results when the environment is changed somewhere else in meantime.
    ; If this commands adds new keys to environment, this cannot be currently reversed.
    __New(changes, mode = "permanent") {
        this._changes := changes
        this._mode := mode
    }

    Run(controller) {
        changes := this._changes
        if (this._mode == "permanent") {
            controller.UpdateEnvironment(changes)
        }
        else if (this._mode == "untilGuiClosed") {
            oldValues := controller.UpdateEnvironment(changes)
            controller.GetGui().SubscribeGuiClosing(this._Revert.Bind(this, oldValues, controller)
                                                      , "once")
        }
    }

    _Revert(oldValues, controller) {
        controller.UpdateEnvironment(oldValues)
    }
}
