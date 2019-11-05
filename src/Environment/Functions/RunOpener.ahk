RunOpenerChange() {
    function := Func("RunOpener")
    return  { functions: { open: function } }
}

RunOpener(env, programName, argument) {
    if (programName != "") {
        target := programName " """ argument """"
    } else {
        target := argument
    }
    Run, %target%
}
