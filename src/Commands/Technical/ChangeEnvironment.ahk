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

    Run(mainController) {
        changes := this._changes
        if (this._mode == "permanent") {
            mainController.UpdateEnvironment(changes)
        }
        else if (this._mode == "untilGuiClosed") {
            oldValues := mainController.UpdateEnvironment(changes)
            mainController.GetGui().SubscribeGuiClosing(this._Revert.Bind(this, oldValues, mainController)
                                                      , "once")
        }
    }

    _Revert(oldValues, mainController) {
        mainController.UpdateEnvironment(oldValues)
    }
}
