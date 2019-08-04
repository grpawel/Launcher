class ExecutableService {
    __New(topLevelExecutable, environment) {
        this._topLevelExecutable := topLevelExecutable
        this._currentExecutable := topLevelExecutable
        this._environment := environment
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
            return executable.Execute(param, this._environment, this)
        }
    }

    GetCurrentExecutable() {
        return this._currentExecutable
    }

    GetTitle() {
        return this._currentExecutable.GetTitle()
    }

    UpdateEnvironment(changes) {
        this._environment := this._environment.WithOverrides(changes)
    }
}

