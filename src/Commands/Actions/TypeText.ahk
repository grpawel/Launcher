#Include %A_ScriptDir%\src\Commands\Command.ahk

; Options:
; when: "guiDestroyed" (default) - type text after gui is destroyed
; when: "immediate" - type text immediately, probably inside gui window (useful in specific cases)
class TypeText extends Command {
    static DEFAULT_OPTIONS := { when: "guiDestroyed" }
    __New(string, options = "") {
        this._string := string
        this._options := MergeArrays(this.DEFAULT_OPTIONS, options)
        this._description := "Type " . string
        this.AddTags(["usesEnv", "funcType"])

        static V := new ValidatorFactory()
        static VAL := V.Object({ "when": V.OneOf(["guiDestroyed" ,"immediate"]) })
        VAL.ValidateAndShow(this._options)
    }

    Run(contr, context) {
        string := GetValue(this._string, contr, context)
        env := contr.GetEnvironment()
        if (this._options.when == "immediate") {
            env.CallFunction("type", "", string)
        } else if (this._options.when == "guiDestroyed") {
            contr.RunCommand(new WaitForGuiDestroyed(new CallEnvFunction("type", "", string)))
        }
    }
}
