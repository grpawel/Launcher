#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Grouping\GuiCommandBuilder.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Helpers\WithCommandsFromFile.ahk

; Export commands from file to format usable in .ahk files.
; `comFile` - `CommandsFile` object
class ExportFileCommands extends Command {
    __New(comFile) {
        this._commandsFile := comFile
    }

    Run(contr, context) {
        valuesList := this._commandsFile.ReadCommandsValues()
        str := ""
        for key, value in valuesList {
            constructorArgs := Join(Wrap(value.fields, """", """"), ", ")
            str .= "`ncomSet.AddCommand(""" value.key """, new " value.name "(" constructorArgs "))"
        }
        env := contr.GetEnvironment()
        env.CallFunction("show", "", str)
    }
}
