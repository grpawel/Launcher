#Include %A_ScriptDir%\src\Commands\Command.ahk

class Web extends Command {
    tags := ["web", "hasPath"]

    __New(url) {
        this._url := url
        this.description := "Open " url
    }

    Run(mainController) {
        env := mainController.GetEnvironment()
        env.OpenWebsite(this._url)
    }
}