#Include <windows-desktop-switcher/functions>
 
#Include %A_ScriptDir%\src\Commands\Command.ahk

class ChangeDesktop extends Command {
    __New(num) {
        this._number := num
    }

    Run(controller) {
        SwitchDesktopByNumber(this._number)
    }
}
