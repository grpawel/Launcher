#Include %A_ScriptDir%\src\Environment\Opener.ahk

class RunOpener extends Opener {
    Default(argument) {
        this._Open(argument, "")
    }

    Website(website, environment) {
        this._Open(website, environment.browser)
    }

    Folder(folder, environment) {
        this._Open(folder, environment.folderProgram)
    }

    File(file, environment) {
        this._Open(file, environment.fileProgram)
    }

    _Open(argument, programName) {
        if (programName != "") {
            command := programName " """ argument """"
        }
        else {
            command := argument
        }
        Run, %command%
    }
}
