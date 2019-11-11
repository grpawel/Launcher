#Include %A_ScriptDir%\src\Commands\Command.ahk

; Show string in separate window.
class ShowInWindow extends Command {
    static DEFAULT_OPTIONS := { disablePrevious: false }

    __New(string) {
        this._string := string
        this._description := "Show string in window"
        this.AddTags(["usesEnv", "funcShow"])
    }

    Run(contr, context) {
        string := GetValue(this._string, contr, context)
        env := contr.GetEnvironment()
        env.CallFunction("show", "", string)
    }
}
