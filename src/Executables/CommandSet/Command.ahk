class Command {
    description := "-"

    __Call(method, environment, executableService) {
        if (method == "Run" || method == "") {
            result := this.Run(environment, executableService)
            if (result == "") {
                return true
            }
            return result
        }
    }

    Run(environment, executableService) {
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