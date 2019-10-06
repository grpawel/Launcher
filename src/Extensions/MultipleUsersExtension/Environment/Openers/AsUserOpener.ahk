; Runs command as different user using `runas` (Windows utility).
; User name is taken from environment ("user" key).
AsUserOpener() {
    function := Func("_AsUserOpener")
    return  { "OpenOther": function.Bind("otherProgram")
            , "OpenWebsite": function.Bind("browser")
            , "OpenFile": function.Bind("fileProgram")
            , "OpenFolder": function.Bind("folderProgram") }
}

_AsUserOpener(programNameKey, env, argument) {
    programName := env[programNameKey]
    userName := env.user
    ; Fix for Firefox not working properly with RunAs, regardless of -no-remote or -new-instance options.
    ; Instead use Firefox profiles.
    if (InStr(programName, "firefox") || InStr(argument, "firefox")) {
        return _UseFirefoxProfileFix(programName, argument, userName)
    }
    ; Fix for Windows Explorer
    if (programName == "explorer") {
        userName := ""
    }

    if (programName != "") {
        target := programName " """ argument """"
    }
    else {
        target := argument
    }

    if (userName != "") {
        target := StrReplace(target, """")
        target := "C:\Windows\System32\runas.exe /user:" userName " /savecreds " """" target """"
    }
    Run, %target%
}

_UseFirefoxProfileFix(firefoxPath, argument, userName) {
    if (userName == "") {
        target := firefoxPath " " argument " -P default-release"
    } else {
        target := firefoxPath " " argument " -P " userName
    }
    ; Fix for running Firefox directly. In this case firefoxPath is empty and "firefox" is in argument,
    ; so there's space as first char that breaks ahk.
    target := Trim(target)
    Run, %target%
}
