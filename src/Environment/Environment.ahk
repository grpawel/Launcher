#Include %A_ScriptDir%\src\Environment\Openers\RunOpener.ahk

class Environment {
    browser := new RunOpener("")
    fileOpener := new RunOpener("")
    folderOpener := new RunOpener("explorer")
    defaultOpener := new RunOpener("")

    WithOverrides(overrides) {
        copy := ObjectDeepCopy(this)
        overridden := ObjectDeepAssign(copy, overrides)
        return overridden
    }
}