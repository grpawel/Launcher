#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk
#Include %A_ScriptDir%\src\Executables\Executable.ahk

class Search extends Command {
    tags := ["web"]

    __New(urlTemplate, title) {
        this._searchExecutable := new WebSearchExecutable(urlTemplate, title)
        this.description := title
    }

    Run(environment, executableService) {
        executableService.ChangeExecutable(this._searchExecutable)
        global level := level + 1
        GuiAddInput("onlyEnter")
        return false
    }
}

class WebSearchExecutable extends Executable {
    subscribedTo := ["returnPressed"]

    __New(urlTemplate, title) {
        this._urlTemplate := urlTemplate
        this.title := title
    }
    Execute(query) {
        url := StrReplace(this._urlTemplate, "REPLACEME", query)
        run, %url%
        return true
    }
}