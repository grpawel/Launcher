#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class File extends Command {
    tags := ["file"]

    __New(path) {
        this._path := path
        this.description := "Open file " path
    }

    Run(environment) {
        environment.fileOpener.Open(this._path)
    }
}