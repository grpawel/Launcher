#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\CommandDialogBuilder.ahk

; Export commands from file to format usable in .ahk files.
; `comFile` - `CommandsFile` object
class ExportFileCommands extends Command {
    __New(comFile) {
        this._commandsFile := comFile
    }

    Run(contr, context) {
        dtoList := this._commandsFile.ReadCommandDTOs()
        str := ""
        for key, dto in dtoList {
            constructorArgs := Join(Wrap(dto.fields, """", """"), ", ")
            str .= "`ncomSet.AddCommand(""" dto.key """, new " dto.name "(" constructorArgs "))"
        }
        env := contr.GetEnvironment()
        env.CallFunction("show", "", str)
    }
}
