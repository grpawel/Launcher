#Include %A_ScriptDir%\src\Commands\Command.ahk

class Search extends Command {

    _keyPressedSubscription :=

    __New(urlTemplate) {
        this._urlTemplate := urlTemplate
        this.AddTags(["web", "hasPath"])
    }

    Run(mainController) {
        mainController.GetGui().DisableAll()
        guiControl := mainController.GetGui().AddTextInput({ header: this.GetDescription() })
        this._keyPressedSubscription := guiControl.SubscribeReturnPressed(this._OnUserInput.Bind(this, mainController))
    }

    _OnUserInput(mainController, input) {
        this._keyPressedSubscription.Unsubscribe()
        url := StrReplace(this._urlTemplate, "REPLACEME", input)
        url := StrReplace(url, " ", "+")
        env := mainController.GetEnvironment()
        env.OpenWebsite(url)
        mainController.GetGui().Destroy()
    }

    DoesNeedGui() {
        return true
    }
}
