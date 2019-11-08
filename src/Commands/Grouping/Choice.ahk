#Include %A_ScriptDir%\src\Commands\Command.ahk

; Select command based on output of some function.
; `function` receives controller, context and `choices` (second argument to this command).
; Should return some string key.
; `choices` is map from keys returned by function to command.
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
    __New(function, choices) {
        this._function := function
        this._choices := choices
        this._selectedCommandNeedsGui := false
    }

    Run(contr, context) {
        function := this._function
        selectedKey := %function%(contr, context, this._choices)
        com := this._choices[selectedKey]
        this._selectedCommandNeedsGui := com.DoesNeedGui()
        contr.RunCommand(com, context)
    }

    DoesNeedGui() {
        return this._selectedCommandNeedsGui
    }
}
