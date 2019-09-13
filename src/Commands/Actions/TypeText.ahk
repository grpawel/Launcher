#Include %A_ScriptDir%\src\Commands\Command.ahk

class TypeText extends Command {
    tags := ["web", "hasPath"]

    __New(string) {
        this._string := string
        this.description := "Type " . string
    }

    Run(mainController) {
        env := mainController.GetEnvironment()
        mainController.GetGui().Hide()
        env.Type(this._string)
    }
}