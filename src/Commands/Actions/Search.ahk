#Include %A_ScriptDir%\src\Commands\Command.ahk

class Search extends Command {
    tags := ["web", "hasPath"]
    doesNeedGui := true

    _keyPressedSubscription :=

    __New(urlTemplate, title) {
        this._urlTemplate := urlTemplate
        this.title := title
        this.description := title
    }

    Run(mainController) {
        mainController.GetGui().DisableAll()
        guiControl := mainController.GetGui().AddTextInput({ title: this.title })
        this._keyPressedSubscription := guiControl.SubscribeReturnPressed(this._OnUserInput.Bind(this, mainController))
    }

    _OnUserInput(mainController, input) {
        this._keyPressedSubscription.Unsubscribe()
        url := StrReplace(this._urlTemplate, "REPLACEME", input)
        env := mainController.GetEnvironment()
        env.Open.Website(url, env)
        mainController.GetGui().Destroy()
    }
}
