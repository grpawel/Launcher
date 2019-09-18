#Include %A_ScriptDir%\src\Environment\Opener.ahk

; Runs command as different user using `runas` (Windows utility).
; User name is taken from constructor, if none then from environment.
class AsUserOpener extends Opener {
    __New(userName = "") {
        this._userName := userName
    }

    GetEnvironmentChanges() {
        return  { "OpenOther": this._Open.Bind(this, "otherProgram")
                , "OpenWebsite": this._Open.Bind(this, "browser")
                , "OpenFile": this._Open.Bind(this, "fileProgram")
                , "OpenFolder": this._Open.Bind(this, "folderProgram") }
    }

    _Open(programNameKey, env, argument) {
        programName := env[programNameKey]
        if (this._userName != "") {
            userName := this._userName
        }
        ; Fix for Firefox not working properly with RunAs, regardless of -no-remote or -new-instance options.
        ; Instead use Firefox profiles.
        if (InStr(programName, "firefox")) {
            return this._UseFirefoxProfileFix(argument, programName, userName)
        }

        if (programName != "") {
            target := programName " """ argument """"
        }
        else {
            target := argument
        }

        if (userName != "") {
            target := StrReplace(target, """")
            target := "C:\Windows\System32\runas.exe /user:" userName " /savecreds " """" target """"
        }
        Run, %target%
    }

    _UseFirefoxProfileFix(argument, firefoxPath, userName) {
        if (userName == "") {
            target := firefoxPath " " argument " -P default-release"
        } else {
            target := firefoxPath " " argument " -P " userName
        }
        Run, %target%
    }
}
