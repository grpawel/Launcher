#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Grouping\GuiCommandBuilder.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Helpers\WithCommandsFromFile.ahk

; Delete command saved in a file.
class GuiDeleteCommand extends Command {
    __New(comFile) {
        this._commandsFile := comFile
        this._description := "Delete command using GUI"
    }

    Run(contr, context) {
        new GuiCommandBuilder()
            .SelectExisting(this._commandsFile)
            .ShowSummary("Deleting command: Close GUI to cancel")
            .DeleteFromFile(this._commandsFile)
            .ShowSummary("Command deleted!")
            .Create()
            .Run(contr, context)
    }

    DoesNeedGui() {
        return true
    }
}
