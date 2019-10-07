#Include %A_ScriptDir%\src\Events\EventBus.ahk
#Include %A_ScriptDir%\src\Environment\Openers\RunOpener.ahk
#Include %A_ScriptDir%\src\Environment\Openers\SendTyper.ahk

class Controller {
    _rootCommand := {}
    _eventBus := new EventBus()

    __New(environment, gui) {
        this._environment := environment
        this._gui := gui
        this._SetDefaultEnvironment()
    }

    _SetDefaultEnvironment() {
        this.UpdateEnvironment(RunOpener())
        this.UpdateEnvironment(SendTyper())
    }

    Execute() {
        if (!this._gui.IsVisible()) {
            if (this._rootCommand.DoesNeedGui()) {
                this._gui.Show()
            }
            this._eventBus.Emit("rootCommandAboutToRun", { rootCommand: this._rootCommand })
            this.RunCommand(this._rootCommand)
        } else {
            this._gui.Destroy()
        }
    }

    SetRootCommand(rootCommand) {
        this._rootCommand := rootCommand
    }

    GetEnvironment() {
        return this._environment
    }

    GetGui() {
        return this._gui
    }

    ; Updates environment with changes. Currently there is no way to remove keys.
    ; Returns object with changed keys in environment. Does not recurse. 
    ; Newly added keys from `changes` are ignored.
    UpdateEnvironment(changes) {
        oldChangedValues := {}
        newEnvironment := this._environment.WithOverrides(changes)
        for key, oldValue in this._environment {
            newValue := newEnvironment[key]
            if (oldValue != newValue) {
                oldChangedValues[key] := oldValue
            }
        }
        this._environment := newEnvironment
        return oldChangedValues
    }

    RunCommand(com, context = "") {
        this._eventBus.Emit("commandAboutToRun", { nextCommand: com })
        if (this._commandBlocked) {
            this._ShowBlockMessage()
            this._commandBlocked := false
            this._blockingReason := ""
        } else {
            com.Run(this, context)
        }
    }

    _ShowBlockMessage() {
        message := "Command blocked."
        if (this._blockingReason != "") {
            message .= " Reason:`n"
            message .= this._blockingReason
        }
        this.ShowErrorMessage(message)
    }

    SubscribeCommandAboutToRun(subscriber, duration = "everytime") {
        return this._eventBus.Subscribe("commandAboutToRun", subscriber, duration)
    }

    SubscribeRootCommandAboutToRun(subscriber, duration = "everytime") {
        return this._eventBus.Subscribe("rootCommandAboutToRun", subscriber, duration)
    }

    BlockNextCommand(reason := "") {
        this._commandBlocked := true
        this._blockingReason := reason
    }

    ShowErrorMessage(message) {
        this._gui.AddText({ text: message, textColor: Colors.RED, textColorDisabled: Colors.RED })
        this._gui.DisableDestroying()
        this._gui.DisableAll()
        ; command (eg. CommandSet) could close Gui after "successful" running of command.
        ; Temporarily disable closing Gui so the user can see the message.
        destroyer := this._EnableGuiDestroying.Bind(this)
        SetTimer, %destroyer%, -0

    }

    _EnableGuiDestroying() {
        this._gui.EnableDestroying()
    }
}
