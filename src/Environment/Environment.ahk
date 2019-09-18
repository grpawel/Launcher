class Environment {
    otherProgram := ""
    browser := "C:\Program Files\Mozilla Firefox\firefox.exe"
    fileProgram := ""
    folderProgram := "explorer"

    ; Functions for opening, typing etc. various things.
    ; Should be called like env.OpenOther(someArgument), 
    ; because then env is supplied as first parameter to the function.
    OpenOther := 
    OpenWebsite := 
    OpenFile := 
    OpenFolder := 
    TypeText := 

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