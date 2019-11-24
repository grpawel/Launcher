#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\CommandDialogBuilder.ahk

; Show builder in GUI for simple commands.
; Command is then saved to a file.
class CreateCommandDialog extends Command {
    __New(comFile) {
        this._commandsFile := comFile
        this._description := "Create command using GUI"
    }

    Run(contr, context) {
        contr.RunCommand( new CommandDialogBuilder()
                           .SelectCommandClass()
                           .ConstructorFields()
                           .KeyDescriptionTags()
                           .SaveToFile(this._commandsFile)
                           .ShowSummary("Command created!")
                           .Build()
                        , context)
    }

    DoesNeedGui() {
        return true
    }
}
