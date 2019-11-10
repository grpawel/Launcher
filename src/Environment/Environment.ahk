#Include %A_ScriptDir%\src\Environment\ImportFunctions.ahk

class Environment {
    settings := { browser: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
                , file: ""
                , folder: "explorer"
                , default: "" }

    ; Functions for opening, typing etc.
    ; Arguments: this object, setting, user argument
    functions := { open: Func("RunOpener")
                 , copy: Func("CopyToClipboard")
                 , type: Func("SendTyper") }

    ; Call function with given name.
    ; `settingName` is taken from environment (e.g. program name). Can be empty.
    ; `argument` can be e.g. file to open or text to type.
    ; Examples:
    /*
    env.CallFunction("open", "browser", "https://google.com")
    env.CallFunction("copy", "", "this text would be copied to clipboard")
    */
    CallFunction(functionName, settingName, argument) {
        function := this.functions[functionName]
        setting := this.settings[settingName]
        %function%(this, setting, argument)
    }

    ; Change settings or functions in this environment. 
    ; Returns old values.
    ; Currently only possible to update or add new entries, not remove them.
    ; Can add new settings or functions not listed be default in this file.
    ; Example: 
    /*
    env.Update({ settings: { browser: "firefox" } })
    */
    Update(changes) {
        oldValues := {}
        for groupName, group in changes {
            EnsureHasKey(this, groupName, {})
            for key, newValue in group {
                EnsureHasKey(oldValues, groupName, {})
                oldValues[groupName][key] := this[groupName][key]
                this[groupName][key] := newValue
            }
        }
        return oldValues
    }

    GetSetting(settingName) {
        return this.settings[settingName]
    }
}
