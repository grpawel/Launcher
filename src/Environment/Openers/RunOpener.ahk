#Include %A_ScriptDir%\src\Environment\Opener.ahk

class RunOpener extends Opener {
    __New(programName) {
        this._programName := programName
    }

    Open(argument) {
        if (this._programName <> "") {
            command := this._programName " """ argument """"
        }
        else {
            command := argument
        }
        Run, %command%
    }
}

