#Include %A_ScriptDir%\src\Events\EventBus.ahk
#Include %A_ScriptDir%\src\Environment\Openers\RunOpener.ahk
#Include %A_ScriptDir%\src\Environment\Openers\SendTyper.ahk

class MainController {
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
        this._gui.ToggleWindow()
        if (this._gui.IsVisible()) {
            this.RunRootCommand()
        }
    }

    SetRootCommand(rootCommand) {
        this._rootCommand := rootCommand
    }
    
    RunRootCommand() {
        rootCommand := this._rootCommand
        %rootCommand%(this)
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
            %com%(this, context)
        }
    }

    _ShowBlockMessage() {
        message := "Command blocked."
        if (this._blockingReason != "") {
            message .= " Reason:`n"
            message .= this._blockingReason
        }
        MsgBox, %message%
    }

    SubscribeCommandAboutToRun(subscriber, duration = "everytime") {
        return this._eventBus.Subscribe("commandAboutToRun", subscriber, duration)
    }

    BlockNextCommand(reason := "") {
        this._commandBlocked := true
        this._blockingReason := reason
    }

}
