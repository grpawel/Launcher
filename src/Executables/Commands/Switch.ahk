#Include %A_ScriptDir%\src\Executables\Commands\Command.ahk

class Switch extends Command {
    __New(newCommandSet) {
       this._newCommandSet := newCommandSet
    }
    Run() {
        global currentExecutable := this._newCommandSet
        global level := level +1
        GuiAddInput("eachKey")
        return false
    }
}