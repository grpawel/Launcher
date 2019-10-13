class CommandBlocker {
    _blockers := []

    ; Add blocker.
    ; `predicate` - function that takes `Command` and `Controller` for parameters
    ;   and returns `true` or string with reason if command should be blocked, false otherwise.
    ; Options:
    ; fallbackReason - reason displayed if predicate returned true
    ; quiet (default: `false`) - do not display message to user

    AddBlocking(predicate, options := "") {
        static DEFAULT_OPTIONS := { fallbackReason: ""
                                  , quiet: false}
        static V := new ValidatorFactory()
        static VAL := V.Object({ "fallbackReason": V.String()
                               , "quiet": V.Boolean() }
                            , { ignoreMissing: false, noOtherKeys: true })
        options := MergeArrays(DEFAULT_OPTIONS, options)
        VAL.ValidateAndShow(options)
        blocker := new this._Blocker(predicate, options)
        this._blockers.Push(blocker)
        return blocker
    }

    ; Remove blocker. 
    ; `blockerToRemove` should be object returned from `Add[Predicate]Blocker` method.
    ; Returns true if removed, false if not found.
    Unblock(blockerToRemove) {
        for i, blocker in this._blockers {
            if (blockerToRemove == blocker) {
                this._blockers.Remove(i)
                return true
            }
        }
        return false
    }

    ; Returns
    ;   `false` if command is allowed to run
    ;   `true` if command is blocked, but no message should be shown
    ;   string message to show to user if command is blocked.
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
        __New(predicate, options) {
            this._predicate := predicate
            this._options := options
        }

        IsCommandBlocked(com, contr) {
            predicate := this._predicate
            returned := %predicate%(com, contr)
            if (returned == false) {
                return false
            } else {
                return this._DetermineMessage(returned)
            }
        }

        _DetermineMessage(reason) {
            if (this._options.quiet) {
                return true
            }
            if (reason == true) {
                return this._options.fallbackReason
            } else {
                return reason
            }
        }
    }
}
