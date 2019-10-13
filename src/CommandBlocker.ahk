class CommandBlocker {
    _blockers := []

    ; Add blocker.
    ; `predicateOrName` - either:
    ;   - function that takes `Command` and `Controller` for parameters
    ;     and returns `true` or string with reason if command should be blocked, false otherwise.
    ;   - name of previously added blocker. In this case options are ignored.
    ; Options:
    ; fallbackReason - reason displayed if predicate returned true
    ; quiet (default: `false`) - do not display message to user
    ; name - blocker name. Can be used to unblock later.
    ;        Existing blocker with same name is replaced.
    ; Returns blocker name.

    AddBlocking(predicateOrName, options := "") {
        if (IsObject(predicateOrName)) {
            return this._AddBlockingPredicate(predicateOrName, options)
        } else {
            this._EnableBlocker(predicateOrName)
            return predicateOrName
        }
    }

    _AddBlockingPredicate(predicate, options := "") {
        static DEFAULT_OPTIONS := { fallbackReason: ""
                                  , quiet: false
                                  , name: ""}
        static V := new ValidatorFactory()
        static VAL := V.Object({ "fallbackReason": V.String()
                               , "quiet": V.Boolean()
                               , "name": V.String() }
                            , { ignoreMissing: false, noOtherKeys: true })
        options := MergeArrays(DEFAULT_OPTIONS, options)
        if (options.name == "") {
            options.name := RandomString(8)
        }
        VAL.ValidateAndShow(options)
        blocker := new this._Blocker(predicate, options)
        this._blockers[options.name] := blocker
        return options.name
    }

    ; Add blocker again 
    _EnableBlocker(name) {
        this._blockers[name].Enable()
    }

    ; Disable blocker using its name.
    ; Returns true if blocker with given name was active, false if not found.
    Unblock(blockerName) {
        if (!this._blockers.HasKey(blockerName)) {
            return false
        }
        this._blockers[blockerName].Disable()
        return true
    }

    ; Returns
    ;   `false` if command is allowed to run
    ;   `true` if command is blocked, but no message should be shown
    ;   string message to show to user if command is blocked.
    IsCommandBlocked(com, contr) {
        for i, blocker in this._blockers {
            res := blocker.IsCommandBlocked(com, contr)
            if (res.doBlock) {
                return res
            }
        }
        return { doBlock: false }
    }

    class _Blocker {
        __New(predicate, options) {
            this._predicate := predicate
            this._options := options
            this._disabled := false
        }

        Disable() {
            this._disabled := true
        }

        Enable() {
            this._disabled := false
        }

        IsCommandBlocked(com, contr) {
            if (this._disabled) {
                return { doBlock: false }
            }
            predicate := this._predicate
            returned := %predicate%(com, contr)
            if (returned == false) {
                return { doBlock: false }
            }
            result := { doBlock: true}
            if (!this._options.quiet) {
                result.message := returned != true ? returned : this._options.fallbackReason
            }
            return result
        }
    }
}
