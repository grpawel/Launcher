#Include %A_ScriptDir%\src\Commands\Command.ahk

class Switch extends Command {
    __New(newCommandSet) {
       this._newCommandSet := newCommandSet
       this.description := "Switch to " newCommandSet.GetTitle()
    }

    Run(mainController) {
        mainController.SetActiveCommand(this._newCommandSet)
        global level := level +1
        GuiAddInput("eachKey")
        return false
    }
}