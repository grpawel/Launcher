#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class ChangeBrowser extends Command {
    __New(browser) {
        this._browser := browser
        this.description := "Change browser to " browser
    }

    Run(environment) {
        environment.browser.ChangeCurrent(this._browser)
    }
}