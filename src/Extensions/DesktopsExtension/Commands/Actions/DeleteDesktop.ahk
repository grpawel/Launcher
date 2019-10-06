#Include <windows-desktop-switcher/functions>
 
#Include %A_ScriptDir%\src\Commands\Command.ahk

class DeleteDesktop extends Command {
    _description := "Delete current desktop"

    Run(mainController) {
        deleteVirtualDesktop()
    }
}
