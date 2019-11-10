#Include %A_ScriptDir%\src\Commands\Command.ahk

class Copy extends Command {
    __New(toCopy) {
        this._toCopy := toCopy
        this._description := "Copy """ toCopy """ to clipboard"
    }

    Run(contr, context) {
        env := contr.GetEnvironment()
        toCopy := GetValue(this._toCopy, contr, context)
        env.CallFunction("copy", "", toCopy)
    }
}
