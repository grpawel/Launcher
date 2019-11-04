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


    ; Change keys in this environment. 
    ; Returns old values.
    ; Currently only possible to update or add new entries, not remove.
    Update(changes) {
        oldValues := {}
        for key, value in changes {
            if (this.HasKey(key)) {
                oldValues[key] := this[key]
            }
            this[key] := changes[key]
        }
        return oldValues
    }
}
