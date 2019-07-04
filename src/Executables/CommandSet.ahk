#Include %A_ScriptDir%\src\Executables\Executable.ahk

class CommandSet extends Executable {
    Execute(input) {
        global previousInputs
        if (not this.commands.HasKey(input)) {
            return false
        }
        command := this.commands[input]
        action := command[1]
        param := command[2]
        previousInputs.Push({input: input, action: action, param: param})
        result := %action%(param)
        if (result == "") {
            return true
        }
        return result
    }
}
