#Include %A_ScriptDir%\src\Commands\Command.ahk

class Folder extends Command {
    tags := ["folder", "hasPath"]

    __New(path) {
        this._path := path
        this.description := "Open folder" path
    }

    Run(mainController) {
        env := mainController.GetEnvironment()
        env.OpenFolder(this._path, env)
    }
}