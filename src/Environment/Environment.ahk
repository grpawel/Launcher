#Include %A_ScriptDir%\src\Environment\ImportFunctions.ahk

class Environment {
    ; Settings can be used to set programs used to open files, websites etc.
    settings := { browser: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
                , file: ""
                , folder: "explorer"
                , default: "" }

    ; Functions for opening, typing etc.
    ; Arguments: this object, setting, user provided argument
    ; By convention these functions are nouns to differentiate them from commands.
    functions := { open: Func("RunOpener")
                 , copy: Func("ToClipboardCopier")
                 , type: Func("SendTyper")
                 , show: Func("InWindowShower")  }

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
    ; Settings or functions not included in `changes` are not affected.
    ; Returns old values.
    ; Currently only possible to update or add new entries, not remove them.
    ; Can add new settings or functions not listed be default in this file.
    ; Example: 
    /*
    oldBrowser := env.Update({ settings: { browser: "firefox" } })
    env.Update(oldBrowser)
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

    GetFunctionNames() {
        return Keys(this.functions)
    }
}
