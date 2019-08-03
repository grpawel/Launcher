#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class Web extends Command {
    __New(url) {
        this._url := url
        this.description := "Open " url
    }

    Run(environment) {
        environment.browser.OpenWebsite(this._url)
    }
}