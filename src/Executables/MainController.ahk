class MainController {
    _rootCommand := {}
    _activeCommand := {}

    __New(environment) {
        this._environment := environment
    }
    
    SetRootCommand(rootCommand) {
        this._rootCommand := rootCommand
        this._activeCommand := rootCommand
    }
    
    ResetToRoot() {
        this._activeCommand := this._rootCommand
    }

    SetActiveCommand(newCommand) {
        this._activeCommand.Deactivate(this)
        this._activeCommand := newCommand
        this._activeCommand.Activate(this)
    }

    Execute(param, method) {
        if (ArrayContains(this._activeCommand.subscribedTo, method)) {
            return this._activeCommand.Execute(param, this)
        }
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

