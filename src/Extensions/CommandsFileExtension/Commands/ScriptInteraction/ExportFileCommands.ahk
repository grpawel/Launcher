#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\CommandDialogBuilder.ahk

; Export commands from file to format usable in .ahk files.
; `comFile` - `CommandsFile` object
; Format contains lines like this one:
/*
comSet.Add("goo", new Web("google")
                     .SetDescription("Search google")
                     .AddTags(["search", "web"]))
*/
class ExportFileCommands extends Command {
    __New(comFile) {
        this._commandsFile := comFile
        this.AddTags(["usesEnv", "funcShow"])
        this._description := "Export commands file"
    }

    Run(contr, context) {
        dtoList := this._commandsFile.ReadCommandDTOs()
        str := ""
        indent := RepeatString(" ", 21)
        for key, dto in dtoList {
            constructorArgs := Join(Wrap(dto.fields, """", """"), ", ")
            str .= "`ncomSet.Add(""" dto.key """, new " dto.name "(" constructorArgs ")"
            if (dto.description != "") {
                str .= "`n" indent ".SetDescription(""" dto.description """)"
            }
            if (HasAnyKey(dto.tags)) {
                tagsStr := "[" Join(Wrap(dto.tags, """", """"), ", ") "]"
                str .= "`n" indent ".AddTags(" tagsStr ")"
            }
            str .= ")"
        }
        env := contr.GetEnvironment()
        env.CallFunction("show", "", str)
    }
}
