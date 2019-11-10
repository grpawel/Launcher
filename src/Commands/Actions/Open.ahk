#Include %A_ScriptDir%\src\Commands\Command.ahk

class Open extends Command {
    __New(toRun, envSetting = "default") {
        this._toRun := toRun
        this._description := "Open " this._toRun
        this._envSetting := envSetting
        this.AddTags(["hasPath"])
    }

    Run(contr) {
        env := contr.GetEnvironment()
        env.CallFunction("open", this._envSetting, this._toRun)
    }
}
