#Include %A_ScriptDir%\src\Commands\Command.ahk

class Open extends Command {
    __New(toRun) {
        this._toRun := toRun
        this._description := "Open " this._toRun
        this.AddTags(["hasPath"])
    }

    Run(mainController) {
        env := mainController.GetEnvironment()
        env.OpenOther(this._toRun)
    }
}
