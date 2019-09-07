class MainController {
    _rootCommand := {}
    _activeCommand := {}

    __New(environment) {
        this._environment := environment
    }
    
    SetRootCommand(rootCommand) {
        this._rootCommand := rootCommand
    }
    
    ResetToRoot() {
        this.SetActiveCommand(this._rootCommand)
    }

    SetActiveCommand(newCommand) {
        oldCommand := this._activeCommand
        oldCommand.Deactivate(this)
        global eventBus
        eventBus.Emit("CommandDeactivated", oldCommand)
        this._activeCommand := newCommand
        this._activeCommand.Activate(this)
    }

    GetActiveCommand() {
        return this._activeCommand
    }

    GetTitle() {
        return this._activeCommand.GetTitle()
    }

    GetEnvironment() {
        return this._environment
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
}
