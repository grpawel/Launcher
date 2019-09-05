#Include %A_ScriptDir%\src\Commands\Command.ahk

class File extends Command {
    tags := ["file", "hasPath"]

    __New(path) {
        this._path := path
        this.description := "Open file " path
    }

    Run(mainController) {
        env := mainController.GetEnvironment()
        env.Open.File(this._path, env)
    }
}