class BaseCommandSet {
    Execute(input) {
        return false
    }
}

class CommandSet extends BaseCommandSet {
    Execute(input) {
        global previousInputs
        if (not this.commands.HasKey(input)) {
            return [false, "not found"]
        }
        command := this.commands[input]
        action := command[1]
        param := command[2]
        previousInputs.Push({input: input, action: action, param: param})
        result := %action%(param)
        if (result == "") {
            return [true, "found"]
        }
        return result
    }
}
