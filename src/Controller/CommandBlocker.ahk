; Mechanism for blocking commands.
; Commands about to run are checked with each rule.
; If a single rule blocks the command, controller would not run the command.
class CommandBlocker {
    _rules := []

    ; Add blocking rule.
    ; `predicateOrName` - either:
    ;   - function that takes `Command` and `Controller` for parameters
    ;     and returns `true` or string if command should be blocked (false otherwise).
    ;     String should contain reason for blocking and can be displayed to the user.
    ;   - name of previously added rule. In this case options are ignored.
    ; Options:
    ; fallbackReason - reason displayed if predicate returned true
    ; quiet (boolean, default: `false`) - do not display message to user
    ; name (string) - rule name. Can be used to disable the rule later.
    ;        Existing rule with same name would be replaced.
    ; Returns rule name.

    AddRule(predicateOrName, options := "") {
        if (IsObject(predicateOrName)) {
            return this._AddRulePredicate(predicateOrName, options)
        } else {
            this.EnableRule(predicateOrName)
            return predicateOrName
        }
    }

    _AddRulePredicate(predicate, options := "") {
        static DEFAULT_OPTIONS := { fallbackReason: ""
                                  , quiet: false
                                  , name: ""}
        static V := new ValidatorFactory()
        static VAL := V.Object({ "fallbackReason": V.String()
                               , "quiet": V.Boolean()
                               , "name": V.String() })
        options := MergeArrays(DEFAULT_OPTIONS, options)
        if (options.name == "") {
            options.name := RandomString(8)
        }
        VAL.ValidateAndShow(options)
        rule := new this._Rule(predicate, options)
        this._rules[options.name] := rule
        return options.name
    }

    ; Enable existing rule again 
    EnableRule(name) {
        this._rules[name].Enable()
    }

    ; Disable rule using its name.
    ; Returns false if rule was not found.
    DisableRule(ruleName) {
        if (!this._rules.HasKey(ruleName)) {
            return false
        }
        this._rules[ruleName].Disable()
        return true
    }

    ; Returns object: 
    ; { doBlock (boolean) - true if any of the enabled rules would block
    ; , message (string) - message to display to the user (set if `doBlock` is `true`).
    ;                      If more rules would block, message is from a single rule chosen in no particular order.
    IsCommandBlocked(com, contr) {
        for i, rule in this._rules {
            result := rule.IsCommandBlocked(com, contr)
            if (result.doBlock) {
                return result
            }
        }
        return { doBlock: false }
    }

    class _Rule {
        __New(predicate, options) {
            this._predicate := predicate
            this._options := options
            this._isDisabled := false
        }

        Disable() {
            this._isDisabled := true
        }

        Enable() {
            this._isDisabled := false
        }

        IsCommandBlocked(com, contr) {
            if (this._isDisabled) {
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
