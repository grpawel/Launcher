class MainController {
    _rootCommand := {}

    __New(environment, gui) {
        this._environment := environment
        this._gui := gui
    }
    
    SetRootCommand(rootCommand) {
        this._rootCommand := rootCommand
    }
    
    RunRootCommand() {
        command := this._rootCommand
        %command%(this)
    }

    GetTitle() {
        return this._activeCommand.GetTitle()
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
}
