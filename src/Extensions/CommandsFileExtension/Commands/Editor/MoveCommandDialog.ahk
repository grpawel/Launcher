#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\CommandDialogBuilder.ahk

; Move command from one file to another.
class MoveCommandDialog extends Command {
    __New(fromFile, toFile) {
        this._fromFile := fromFile
        this._toFile := toFile
        this._description := "Move command between files"
    }

    Run(contr, context) {
        new CommandDialogBuilder()
            .SelectExisting(this._fromFile)
            .ShowSummary("Moving command: Close GUI to cancel")
            .DeleteFromFile(this._fromFile)
            .SaveToFile(this._toFile)
            .ShowSummary("Command moved!")
            .Build()
            .Run(contr, context)
    }

    DoesNeedGui() {
        return true
    }
}
