#Include %A_ScriptDir%\src\Commands\Command.ahk

class File extends Command {
    __New(path) {
        this._path := path
        this._description := "Open file " path
        this.AddTags(["file", "hasPath"])
    }

    Run(contr, context) {
        env := contr.GetEnvironment()
        path := GetValue(this._path, contr, context)
        env.CallFunction("open", "file", this._path)
    }
}
