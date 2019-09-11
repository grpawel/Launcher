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
        global globalEventBus
        guiControl := mainController.GetGui().AddTextInput({ title: this.title })
        this._keyPressedSubscription := globalEventBus.Subscribe("returnPressed", this._OnUserInput.Bind(this, mainController))
    }

    _OnUserInput(mainController, input) {
        this._keyPressedSubscription.Unsubscribe()
        url := StrReplace(this._urlTemplate, "REPLACEME", input)
        env := mainController.GetEnvironment()
        env.Open.Website(url, env)
        mainController.GetGui().Hide()
    }
}
