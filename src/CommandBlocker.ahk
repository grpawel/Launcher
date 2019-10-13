class CommandBlocker {
    _blockers := []

    ; Add blocker.
    ; `predicate` - function that takes `Command` and `Controller` for parameters
    ;   and returns string with reason if command should be blocked, false otherwise.
    ;   If `predicate` returns true instead of string, reason is taken from `fallbackReason`.

    AddBlocker(predicate, fallbackReason := "") {
        blocker := new this._Blocker(predicate, fallbackReason)
        this._blockers.Push(blocker)
        return blocker
    }

    ; Remove blocker. 
    ; `blockerToRemove` should be object returned from `Add[Predicate]Blocker` method.
    ; Returns true if removed, false if not found.
    RemoveBlocker(blockerToRemove) {
        for i, blocker in this._blockers {
            if (blockerToRemove == blocker) {
                this._blockers.Remove(i)
                return true
            }
        }
        return false
    }

    ; Returns `false` if command is allowed to run
    ; or string message otherwise.
    IsCommandBlocked(com, contr) {
        for i, blocker in this._blockers {
            returnedMessage := blocker.IsCommandBlocked(com, contr)
            if (returnedMessage != false) {
                return returnedMessage
            }
        }
        return false
    }

    class _Blocker {
        __New(predicate, fallbackReason = "") {
            this._predicate := predicate
            this._fallbackReason := fallbackReason
        }

        IsCommandBlocked(com, contr) {
            predicate := this._predicate
            reason := %predicate%(com, contr)
            if (reason == false) {
                return false
            } else if (reason == true) {
                return this._fallbackReason
            } else {
                return reason
            }
        }
    }
}
