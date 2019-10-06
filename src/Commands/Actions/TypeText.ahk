#Include %A_ScriptDir%\src\Commands\Command.ahk

class TypeText extends Command {
    __New(string) {
        this._string := string
        this._description := "Type " . string
        this.AddTags(["web", "hasPath"])
    }

    Run(mainController) {
        env := mainController.GetEnvironment()
        env.TypeText(this._string)
    }
}