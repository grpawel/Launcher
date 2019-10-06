#Include %A_ScriptDir%\src\Commands\Command.ahk

class Web extends Command {
    __New(url) {
        this._url := url
        this._description := "Open " url
        this.AddTags(["web", "hasPath"])
    }

    Run(mainController) {
        url := StrReplace(this._url, " ", "+")
        env := mainController.GetEnvironment()
        env.OpenWebsite(url)
    }
}