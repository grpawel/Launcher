class Command {
    description := "-"

    __Call(method, args*) {
        if (method == "Run" || method == "") {
            param := args[1]
            result := this.Run(param)
            if (result == "") {
                return true
            }
            return result
        }
    }

    Run(param) {
        throw "Not implemented"
    }

    SetDescription(description) {
        this.description := description
        return this
    }

    GetDescription() {
        return this.description
    }
}