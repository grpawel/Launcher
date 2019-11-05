#Include %A_ScriptDir%\src\Commands\Command.ahk

class Web extends Command {
    __New(url) {
        this._url := url
        this._description := "Open " url
        this.AddTags(["web", "hasPath"])
    }

    Run(controller) {
        url := StrReplace(this._url, " ", "+")
        env := controller.GetEnvironment()
        env.CallFunction("open", "browser", url)
    }
}
