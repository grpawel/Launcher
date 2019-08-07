#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

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

    Run(environment, executableService) {
        if (this._mode == "permanent") {
            executableService.UpdateEnvironment(this._changes)
        }
        else if (this._mode == "untilGuiClosed") {
            oldValues := executableService.UpdateEnvironment(this._changes)
            global eventBus
            eventBus.SubscribeOnce("GuiClosed", ChangeEnvironment._Revert.Bind(this, oldValues, executableService))
        }
    }

    _Revert(oldValues, executableService) {
        executableService.UpdateEnvironment(oldValues)
    }
}
