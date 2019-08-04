#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk

class Switch extends Command {
    __New(newCommandSet) {
       this._newCommandSet := newCommandSet
       this.description := "Switch to " newCommandSet.GetTitle()
    }

    Run(environment, executableService) {
        executableService.ChangeExecutable(this._newCommandSet)
        global level := level +1
        GuiAddInput("eachKey")
        return false
    }
}