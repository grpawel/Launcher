#Include %A_ScriptDir%\src\Environment\Opener.ahk

; Blocks opening of command.
class BlockingOpener extends Opener {
    __New(reason = "") {
        this._reason := reason
    }

    Default(args*) {
        this._Open(args*)
    }

    Website(args*) {
        this._Open(args*)
    }

    Folder(args*) {
        this._Open(args*)
    }

    File(args*) {
        this._Open(*args)
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
