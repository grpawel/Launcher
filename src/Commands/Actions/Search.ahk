#Include %A_ScriptDir%\src\Commands\Command.ahk

class Search extends Command {
    _keyPressedSubscription :=

    __New(urlTemplate) {
        this._urlTemplate := urlTemplate
        this.AddTags(["web", "hasPath"])
    }

    Run(controller) {
        gui := controller.GetGui()
        gui.DisableAll()
        if (this.GetDescription() != "") {
            gui.AddText({ text: this.GetDescription() })
        }
        guiControl := gui.AddTextInput()
        this._keyPressedSubscription := guiControl.SubscribeReturnPressed(this._OnUserInput.Bind(this, controller))
        gui.Show()
    }

    _OnUserInput(controller, input) {
        this._keyPressedSubscription.Unsubscribe()
        url := StrReplace(this._urlTemplate, "REPLACEME", input)
        url := StrReplace(url, " ", "+")
        env := controller.GetEnvironment()
        env.CallFunction("open", "browser", url)
        controller.GetGui().Destroy()
    }

    DoesNeedGui() {
        return true
    }
}
