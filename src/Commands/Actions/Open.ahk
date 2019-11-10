#Include %A_ScriptDir%\src\Commands\Command.ahk

class Open extends Command {
    __New(toRun, envSetting = "default") {
        this._toRun := toRun
        this._description := "Open " this._toRun
        this._envSetting := envSetting
        this.AddTags(["hasPath"])
    }

    Run(contr, context) {
        env := contr.GetEnvironment()
        envSetting := GetValue(this._envSetting, contr, context)
        toRun := GetValue(this._toRun, contr, context)
        env.CallFunction("open", envSetting, toRun)
    }
}
