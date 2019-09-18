#Include %A_ScriptDir%\src\Environment\Opener.ahk

class CopyToClipboardOpener extends Opener {
    GetEnvironmentChanges() {
        return  { "OpenOther": this._Open.Bind(this)
                , "OpenWebsite": this._Open.Bind(this)
                , "OpenFile": this._Open.Bind(this)
                , "OpenFolder": this._Open.Bind(this) }
    }

    _Open(env, argument) {
        Clipboard := argument
    }
}
