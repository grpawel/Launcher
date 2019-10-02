CopyToClipboardOpener() {
    function := Func("_CopyToClipboardOpener")
    return  { "OpenOther": function
            , "OpenWebsite": function
            , "OpenFile": function
            , "OpenFolder": function }
}

_CopyToClipboardOpener(env, argument) {
    Clipboard := argument
}
