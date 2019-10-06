#Include %A_ScriptDir%\src\Commands\Command.ahk

class Folder extends Command {
    __New(path) {
        this._path := path
        this._description := "Open folder" path
        this.AddTags(["folder", "hasPath"])
    }

    Run(mainController) {
        env := mainController.GetEnvironment()
        env.OpenFolder(this._path, env)
    }
}
