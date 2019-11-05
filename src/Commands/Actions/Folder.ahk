#Include %A_ScriptDir%\src\Commands\Command.ahk

class Folder extends Command {
    __New(path) {
        this._path := path
        this._description := "Open folder " path
        this.AddTags(["folder", "hasPath"])
    }

    Run(controller) {
        env := controller.GetEnvironment()
        env.CallFunction("open", "folder", this._path)
    }
}
