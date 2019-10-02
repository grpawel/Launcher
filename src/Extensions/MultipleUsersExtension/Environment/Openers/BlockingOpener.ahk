; Blocks opening of command.
BlockingOpener(reason = "") {
    function := Func("_BlockingOpener")
    return  { "OpenOther": function.Bind(reason)
                , "OpenWebsite": function.Bind(reason)
                , "OpenFile": function.Bind(reason)
                , "OpenFolder": function.Bind(reason) }
}

_BlockingOpener(reason, args*) {
    message := "Cannot run that."
    if (this._reason != "") {
        message .= "`n`nReason:`n" . this._reason
    }
    showFunc := Func("_BlockingOpener_ShowMessage").Bind(message)
    SetTimer, %showFunc%, -60
}

_BlockingOpener_ShowMessage(message) {
    MsgBox, %message%
}
