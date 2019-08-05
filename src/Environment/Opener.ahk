class Opener {
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