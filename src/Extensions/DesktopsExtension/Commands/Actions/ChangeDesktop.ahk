#Include *i <windows-desktop-switcher/functions>
 
#Include %A_ScriptDir%\src\Commands\Command.ahk

class ChangeDesktop extends Command {
    static _SWITCH_DESKTOP_FUNC := Func("SwitchDesktopByNumber")

    __New(num) {
        this._number := num
        this._description := "Change desktop to " num
    }

    Run(controller) {
        this._SWITCH_DESKTOP_FUNC.Call(this._number)
    }
}
