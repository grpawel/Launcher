#Include %A_ScriptDir%\src\Environment\Opener.ahk

; Blocks opening of command.
class BlockingOpener extends Opener {
    __New(reason = "") {
        this._reason := reason
    }

    GetEnvironmentChanges() {
        return  { "OpenOther": this._Open.Bind(this)
                , "OpenWebsite": this._Open.Bind(this)
                , "OpenFile": this._Open.Bind(this)
                , "OpenFolder": this._Open.Bind(this) }
    }

    _Open(args*) {
        message := "Cannot run that."
        if (this._reason != "") {
            message .= "`n`nReason:`n" . this._reason
        }
        showFunc := this._ShowMessage.Bind(this, message)
        SetTimer, %showFunc%, -60
    }

    _ShowMessage(message) {
        MsgBox, %message%
    }
}
