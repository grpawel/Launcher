#Include %A_ScriptDir%\src\Environment\Opener.ahk

; Runs command as different user using `runas` (Windows utility).
; User name is taken from constructor, if none then from environment.
class AsUserOpener extends Opener {
    __New(userName = "") {
        this._userName := userName
    }

    Default(argument, environment = "") {
        this._Open(argument, environment.defaultProgram, environment.user)
    }

    Website(website, environment = "") {
        this._Open(website, environment.browser, environment.user)
    }

    Folder(folder, environment = "") {
        this._Open(folder, environment.folderProgram, environment.user)
    }

    File(file, environment = "") {
        this._Open(file, environment.fileProgram, environment.user)
    }

    _Open(argument, programName, userName) {
        if (this._userName != "") {
            userName := this._userName
        }
        ; Fix for Firefox not working properly with RunAs, regardless of -no-remote or -new-instance options.
        ; Instead use Firefox profiles.
        if (InStr(programName, "firefox")) {
            return this._UseFirefoxProfileFix(argument, programName, userName)
        }

        if (programName != "") {
            command := programName " """ argument """"
        }
        else {
            command := argument
        }

        if (userName != "") {
            command := StrReplace(command, """")
            command := "C:\Windows\System32\runas.exe /user:" userName " /savecreds " """" command """"
        }
        Run, %command%
    }

    _UseFirefoxProfileFix(argument, firefoxPath, userName) {
        if (userName == "") {
            command := firefoxPath " " argument " -P default-release"
        } else {
            command := firefoxPath " " argument " -P " userName
        }
        Run, %command%
    }
}
