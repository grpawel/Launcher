RunOpener(env, programName, argument) {
    if (programName != "") {
        target := programName " """ argument """"
    } else {
        target := argument
    }
    Run, %target%
}
