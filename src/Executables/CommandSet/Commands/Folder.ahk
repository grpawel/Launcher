#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class Folder extends Command {
    tags := ["folder", "hasPath"]

    __New(path) {
        this._path := path
        this.description := "Open folder" path
    }

    Run(executableService) {
        env := executableService.GetEnvironment()
        env.Open.Folder(this._path, env)
    }
}