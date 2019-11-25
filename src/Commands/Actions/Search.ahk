#Include %A_ScriptDir%\src\Commands\Command.ahk

class Search extends Command {
    _keyPressedSubscription :=

    __New(urlTemplate) {
        this._urlTemplate := urlTemplate
        this._description := "Search " urlTemplate
        this.AddTags(["usesEnv", "funcOpen"])
    }

    Run(contr, context) {
        gui := contr.GetGui()
        if (this.GetDescription() != "Search " this._urlTemplate && this.GetDescription() != "") {
            gui.AddText({ text: this.GetDescription() })
        }
        guiControl := gui.AddTextInput()
        this._keyPressedSubscription := guiControl.SubscribeReturnPressed(this._OnUserInput.Bind(this, contr, context))
        gui.Show()
    }

    _OnUserInput(contr, context, input) {
        this._keyPressedSubscription.Unsubscribe()
        urlTemplate := GetValue(this._urlTemplate, contr, context)
        url := StrReplace(GetValue(urlTemplate, contr, context), "REPLACEME", input)
        url := StrReplace(url, " ", "+")
        env := contr.GetEnvironment()
        env.CallFunction("open", "browser", url)
        contr.GetGui().Destroy()
    }

    DoesNeedGui() {
        return true
    }
}
