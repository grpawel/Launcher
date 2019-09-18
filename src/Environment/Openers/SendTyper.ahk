#Include %A_ScriptDir%\src\Environment\Opener.ahk

class SendTyper extends Opener {
    GetEnvironmentChanges() {
        return  { "TypeText": this._Send.Bind(this) }
    }

    _Send(env, string) {
        Send, %string%
    }
}