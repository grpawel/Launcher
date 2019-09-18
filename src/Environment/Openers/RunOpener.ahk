#Include %A_ScriptDir%\src\Environment\Opener.ahk

class RunOpener extends Opener {
    GetEnvironmentChanges() {
        return  { "OpenOther": this._Open.Bind(this, "otherProgram")
                , "OpenWebsite": this._Open.Bind(this, "browser")
                , "OpenFile": this._Open.Bind(this, "fileProgram")
                , "OpenFolder": this._Open.Bind(this, "folderProgram") }
    }

    ; env is supplied by calling functions env.OpenOther(someArgument)
    _Open(programNameKey, env, argument) {
        programName := env[programNameKey]
        if (programName != "") {
            target := programName " """ argument """"
        } else {
            target := argument
        }
        Run, %target%
    }
}
