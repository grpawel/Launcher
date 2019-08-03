class ExecutableService {
    __New(topLevelExecutable) {
        this._topLevelExecutable := topLevelExecutable
        this._currentExecutable := topLevelExecutable
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
            return executable.Execute(param, method)
        }
    }

    GetCurrentExecutable() {
        return this._currentExecutable
    }

    GetTitle() {
        return this._currentExecutable.GetTitle()
    }
}