class ExecutableService {
    _topLevelExecutable := {}
    _currentExecutable := {}

    __New(environment) {
        this._environment := environment
    }
    
    SetTopLevelExecutable(executable) {
        this._topLevelExecutable := executable
        this._currentExecutable := executable
    }
    
    ResetExecutable() {
        this._currentExecutable := this._topLevelExecutable
    }

    ChangeExecutable(newExecutable) {
        this._currentExecutable.OnBeforeExecutableChanged()
        this._currentExecutable := newExecutable
    }

    Execute(param, method) {
        executable := this._currentExecutable
        if (ArrayContains(executable.subscribedTo, method)) {
            return executable.Execute(param, this)
        }
    }

    GetCurrentExecutable() {
        return this._currentExecutable
    }

    GetTitle() {
        return this._currentExecutable.GetTitle()
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

