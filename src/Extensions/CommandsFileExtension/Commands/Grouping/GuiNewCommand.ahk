#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Grouping\GuiCommandBuilder.ahk

; Show builder in GUI for simple commands.
; Command is then saved to a file.
class GuiNewCommand extends Command {
    __New(comFile) {
        this._commandsFile := comFile
        this._description := "Create command using GUI"
    }

    Run(contr, context) {
        new GuiCommandBuilder()
            .SelectCommandClass()
            .ConstructorFields()
            .KeyDescriptionTags()
            .SaveToFile(this._commandsFile)
            .Create()
            .Run(contr, context)
    }

    DoesNeedGui() {
        return true
    }
}
