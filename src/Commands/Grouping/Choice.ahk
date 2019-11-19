#Include %A_ScriptDir%\src\Commands\Command.ahk

; Select command based on output of some function.
; `function` - function called when `Choice` command is run.
;   Receives controller, context and `choices` (second argument to this command).
;   Should return key present in map.
; `choices` - map from keys to commands.
; One of entries in `choices` (by default "default") 
; is used when function returned key not present in `choices`.
; 
; Options:
; defaultKey: string (default "default") - entry from map run when function output matches nothing in map.
; 
; Examples:
/*
WorkOrFreeTime() {
    if (A_Hour >= 9 && A_Hour < 17) {
        return "workTime"
    } else {
        return "freeTime"
    }
}
emails := { "workTime": new Web("workemail.com")
          , "freeTime": new Web("personalemail.com") }
calendars := { "workTime": new Web("workcalendar.com")
             , "freeTime": new Web("personalcalendar.com") }
comset.AddCommand("email", new Choice(Func("WorkOrFreeTime"), emails))
comset.AddCommand("calen", new Choice(Func("WorkOrFreeTime"), calendars))
*/
/*
RandomChoice(contr, context, choices) {
    return RandomKey(choices)
}
NextChoice(contr, context, choices) {
    static next := 1
    if (next > choiceKeys.MaxIndex()) {
        next := 1
    }
    choiceKeys := Keys(choices)
    nextKey := choiceKeys[next]
    next += 1
    return nextKey
}
searches := [ new Web("google.com")
            , new Web("yahoo.com")
            , new Web("duckduckgo.com")
            , new Web("bing.com") ]
comset.AddCommand("rand", new Choice(Func("RandomChoice"), searches))
comset.AddCommand("next", new Choice(Func("NextChoice"), searches))
*/
class Choice extends Command {
    static _DEFAULT_OPTIONS := { defaultKey: "default" }

    __New(function, choices, options = "") {
        this._function := function
        this._choices := choices
        this._options := MergeArrays(this._DEFAULT_OPTIONS, options)
        this._selectedCommandNeedsGui := false
        this.AddTags(["composite"])

        static V := new ValidatorFactory()
        static VAL := V.Object({ "defaultKey": V.String() })
        VAL.ValidateAndShow(this._options)
    }

    Run(contr, context) {
        com := this._GetCommand(contr, context)
        this._selectedCommandNeedsGui := com.DoesNeedGui()
        contr.RunCommand(com, context)
    }

    _GetCommand(contr, context) {
        function := this._function
        selectedKey := %function%(contr, context, this._choices)
        if (!this._choices.HasKey(selectedKey)) {
            selectedKey := this._options.defaultKey
        }
        return this._choices[selectedKey]
    }

    DoesNeedGui() {
        return this._selectedCommandNeedsGui
    }
}
