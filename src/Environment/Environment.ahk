#Include %A_ScriptDir%\src\Environment\Opener.ahk

class Environment {
    browser := new Opener("")
    defaultOpener := new Opener("")

    WithOverrides(overrides) {
        copy := ObjectDeepCopy(this)
        overridden := ObjectDeepAssign(copy, overrides)
        return overridden
    }
}