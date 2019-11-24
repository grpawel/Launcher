#Include *i <windows-desktop-switcher/functions>
 
#Include %A_ScriptDir%\src\Commands\Command.ahk

class DeleteDesktop extends Command {
    static _DELETE_DESKTOP_FUNC := Func("deleteVirtualDesktop")

    _description := "Delete current desktop"

    Run(controller) {
        this._DELETE_DESKTOP_FUNC.Call()
    }
}
