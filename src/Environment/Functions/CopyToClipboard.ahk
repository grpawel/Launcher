CopyToClipboardChange() {
    function := Func("CopyToClipboard")
    return  { functions: { open: function
                         , copy: function
                         , type: function } }
}

CopyToClipboard(env, setting, argument) {
    Clipboard := argument
}
