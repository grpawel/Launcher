#Include %A_ScriptDir%\src\Environment\Browser.ahk

class Environment {
    browser := new Browser("""firefox""")

    WithOverrides(overrides) {
        copy := ObjectDeepCopy(this)
        overridden := ObjectDeepAssign(copy, overrides)
        return overridden
    }
}