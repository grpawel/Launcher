#Include <windows-desktop-switcher/functions>
 
#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class ChangeDesktop extends Command {
    __New(num) {
        this._number := num
    }

    Run(environment, executableService) {
        SwitchDesktopByNumber(this._number)
    }
}
