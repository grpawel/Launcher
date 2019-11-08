#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Grouping\GuiCommandBuilder.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Helpers\WithCommandsFromFile.ahk

; Edit command saved in a file.
; Command is then updated in a file.
; If user changes command class to one with less constructor fields, some values are not shown.
class GuiEditCommand extends Command {
    __New(comFile) {
        this._commandsFile := comFile
        this._description := "Edit command using GUI"
    }

    Run(contr, context) {
        new GuiCommandBuilder()
            .SelectExisting(this._commandsFile)
            .ShowSummary("Editing command: (if you change key, command will be duplicated)")
            .SelectCommandClass()
            .ConstructorFields()
            .KeyDescriptionTags()
            .SaveToFile(this._commandsFile)
            .ShowSummary("Command edited!")
            .Create()
            .Run(contr, context)
    }

    DoesNeedGui() {
        return true
    }
}
