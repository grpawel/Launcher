#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Commands\Executable.ahk

class Search extends Executable {
    tags := ["web", "hasPath"]
    doesNeedGui := true

    _keyPressedSubscription :=

    __New(urlTemplate, title) {
        this._urlTemplate := urlTemplate
        this.title := title
        this.description := title
    }

    Run(mainController) {
        mainController.SetActiveCommand(this)
    }

    Activate(mainController) {
        global eventBus
        this._keyPressedSubscription := eventBus.Subscribe("returnPressed", this._OnUserInput.Bind(this, mainController))
        GuiAddInput()
    }

    Deactivate(mainController) {
        global eventBus
        eventBus.Unsubscribe(this._keyPressedSubscription)
    }

    _OnUserInput(mainController, input) {
        url := StrReplace(this._urlTemplate, "REPLACEME", input)
        env := mainController.GetEnvironment()
        env.Open.Website(url, env)
        gui_destroy()
    }
}
