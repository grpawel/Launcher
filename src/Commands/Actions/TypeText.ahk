#Include %A_ScriptDir%\src\Commands\Command.ahk

class TypeText extends Command {
    __New(string) {
        this._string := string
        this._description := "Type " . string
        this.AddTags(["web", "hasPath"])
    }

    Run(controller) {
        env := controller.GetEnvironment()
        env.CallFunction("type", "", this._string)
    }
}
