#Include %A_ScriptDir%\src\Events\EventBus.ahk
#Include %A_ScriptDir%\src\Environment\Openers\RunOpener.ahk
#Include %A_ScriptDir%\src\Environment\Openers\SendTyper.ahk
#Include %A_ScriptDir%\src\CommandBlocker.ahk

class Controller {
    _rootCommand := {}
    _eventBus := new EventBus()

    __New(environment, gui) {
        this._environment := environment
        this._gui := gui
        this._SetDefaultEnvironment()
        this._blocker := new CommandBlocker()
    }

    _SetDefaultEnvironment() {
        this.UpdateEnvironment(RunOpener())
        this.UpdateEnvironment(SendTyper())
    }

    Execute() {
        if (!this._gui.IsVisible()) {
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
        blockingReason := this._blocker.IsCommandBlocked(com, this)
        if (blockingReason != false) {
            this.ShowErrorMessage(blockingReason)
        }
        else {
            com.Run(this, context)
        }
    }

    SubscribeCommandAboutToRun(subscriber, options = "") {
        return this._eventBus.Subscribe("commandAboutToRun", subscriber, options)
    }

    SubscribeRootCommandAboutToRun(subscriber, options = "") {
        return this._eventBus.Subscribe("rootCommandAboutToRun", subscriber, iptions)
    }

    GetBlocker() {
        return this._blocker
    }

    ShowErrorMessage(message) {
        this._gui.AddText({ text: message, textColor: Colors.RED, textColorDisabled: Colors.RED })
        this._gui.DisableDestroying()
        this._gui.DisableAll()
        this._gui.Show()
        ; command (eg. CommandSet) could close Gui after "successful" running of command.
        ; Temporarily disable closing Gui so the user can see the message.
        destroyer := this._EnableGuiDestroying.Bind(this)
        SetTimer, %destroyer%, -0

    }

    _EnableGuiDestroying() {
        this._gui.EnableDestroying()
    }
}
