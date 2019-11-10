#Include %A_ScriptDir%\src\Commands\Command.ahk

class TypeText extends Command {
    __New(string) {
        this._string := string
        this._description := "Type " . string
        this.AddTags(["web", "hasPath"])
    }

    Run(contr, context) {
        string := GetValue(this._string, contr, context)
        env := contr.GetEnvironment()
        env.CallFunction("type", "", string)
    }
}
