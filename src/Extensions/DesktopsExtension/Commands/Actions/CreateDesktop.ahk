#Include *i <windows-desktop-switcher/functions>
 
#Include %A_ScriptDir%\src\Commands\Command.ahk

class CreateDesktop extends Command {
    static _CREATE_DESKTOP_FUNC := Func("createVirtualDesktop")

    _description := "Create new desktop"

    Run(controller) {
        this._CREATE_DESKTOP_FUNC.Call()
    }
}
