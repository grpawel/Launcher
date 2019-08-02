class ExecutableService {
    __New(topLevelExecutable) {
        this._topLevelExecutable := topLevelExecutable
        this._currentExecutable := topLevelExecutable
    }
    
    ResetExecutable() {
        this._currentExecutable := this._topLevelExecutable
    }

    ChangeExecutable(newExecutable) {
        this._currentExecutable := newExecutable
    }

    Execute(param) {
        return this._currentExecutable.Execute(param)
    }

    GetCurrentExecutable() {
        return this._currentExecutable
    }

    GetTitle() {
        return this._currentExecutable["title"]
    }
}