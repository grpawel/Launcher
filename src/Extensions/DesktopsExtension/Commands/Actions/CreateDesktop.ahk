#Include <windows-desktop-switcher/functions>
 
#Include %A_ScriptDir%\src\Commands\Command.ahk

class CreateDesktop extends Command {
    description := "Create new desktop"

    Run(mainController) {
        createVirtualDesktop()
    }
}
