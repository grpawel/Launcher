; Runs command as different user using `runas` (Windows utility).
; User name is taken from parameter, if none then from environment.
AsUserOpener(userName = "") {
    function := Func("_AsUserOpener")
    return  { "OpenOther": function.Bind(userName, "otherProgram")
            , "OpenWebsite": function.Bind(userName, "browser")
            , "OpenFile": function.Bind(userName, "fileProgram")
            , "OpenFolder": function.Bind(userName, "folderProgram") }
}

_AsUserOpener(userName, programNameKey, env, argument) {
    programName := env[programNameKey]
    userName := userName != "" ? userName : env.user
    ; Fix for Firefox not working properly with RunAs, regardless of -no-remote or -new-instance options.
    ; Instead use Firefox profiles.
    if (InStr(programName, "firefox")) {
        return _UseFirefoxProfileFix(argument, programName, userName)
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

_UseFirefoxProfileFix(argument, firefoxPath, userName) {
    if (userName == "") {
        target := firefoxPath " " argument " -P default-release"
    } else {
        target := firefoxPath " " argument " -P " userName
    }
    Run, %target%
}
