#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk
#Include %A_ScriptDir%\src\Executables\Executable.ahk

class Search extends Command {
    tags := ["web", "hasPath"]

    __New(urlTemplate, title) {
        this._searchExecutable := new WebSearchExecutable(urlTemplate, title)
        this.description := title
    }

    Run(mainController) {
        mainController.SetActiveCommand(this._searchExecutable)
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

    Execute(query, mainController) {
        url := StrReplace(this._urlTemplate, "REPLACEME", query)
        env := mainController.GetEnvironment()
        env.Open.Website(url, env)
        return true
    }
}