#Include %A_ScriptDir%\src\Environment\Openers\RunOpener.ahk

class Environment {
    browser := "firefox"
    fileProgram := ""
    folderProgram := "explorer"
    defaultProgram := ""

    Open := new RunOpener()

    ; Returns new `Environment` with values either from this object or `overrides`.
    ; Existing values are not copied, so changes to them are visible in both objects.
    WithOverrides(overrides) {
        overridden := new Environment()
        for key, value in this {
            if (!overrides.HasKey(key)) {
                overridden[key] := value
            }
        }
        for key, value in overrides {
            overridden[key] := value
        }
        return overridden
    }
}