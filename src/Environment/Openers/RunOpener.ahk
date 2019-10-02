RunOpener() {
    function := Func("_RunOpener")
    return  { "OpenOther": function.Bind("otherProgram")
            , "OpenWebsite": function.Bind("browser")
            , "OpenFile": function.Bind("fileProgram")
            , "OpenFolder": function.Bind("folderProgram") }
}

_RunOpener(programNameKey, env, argument) {
    programName := env[programNameKey]
    if (programName != "") {
        target := programName " """ argument """"
    } else {
        target := argument
    }
    Run, %target%
}
