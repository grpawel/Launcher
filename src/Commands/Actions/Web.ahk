#Include %A_ScriptDir%\src\Commands\Command.ahk

class Web extends Command {
    __New(url) {
        this._url := url
        this._description := "Open " url
        this.AddTags(["web", "hasPath"])
    }

    Run(contr, context) {
        url := GetValue(this._url, contr, context)
        url := StrReplace(url, " ", "+")
        env := contr.GetEnvironment()
        env.CallFunction("open", "browser", url)
    }
}
