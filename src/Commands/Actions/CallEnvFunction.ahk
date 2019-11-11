#Include %A_ScriptDir%\src\Commands\Command.ahk

class CallEnvFunction extends Command {
    __New(envFunctionName, envSetting, argument) {
        this._argument := argument
        this._envFunctionName := envFunctionName
        this._envSetting := envSetting
        this._description := "Call " envFunctionName
        this.AddTags(["usesEnv", "funcOpen"])
    }

    Run(contr, context) {
        env := contr.GetEnvironment()
        envFunctionName := GetValue(this._envFunctionName, contr, context)
        envSetting := GetValue(this._envSetting, contr, context)
        argument := GetValue(this._argument, contr, context)
        env.CallFunction(envFunctionName, envSetting, argument)
    }
}
