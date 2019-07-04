class Command {
    __Call(method, args*) {
        param := args[1]
        result := this.Run(param)
        if (result == "") {
            return true
        }
        return result
    }
}