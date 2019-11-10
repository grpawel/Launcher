#Include %A_ScriptDir%\src\Commands\Command.ahk

class Folder extends Command {
    __New(path) {
        this._path := path
        this._description := "Open folder " path
        this.AddTags(["folder", "hasPath"])
    }

    Run(contr, context) {
        env := contr.GetEnvironment()
        path := GetValue(this._path, contr, context)
        env.CallFunction("open", "folder", path)
    }
}
