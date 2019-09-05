#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class Web extends Command {
    tags := ["web", "hasPath"]

    __New(url) {
        this._url := url
        this.description := "Open " url
    }

    Run(executableService) {
        env := executableService.GetEnvironment()
        env.Open.Website(this._url, env)
    }
}