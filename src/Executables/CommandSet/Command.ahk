class Command {
    description := "-"
    tags := []

    __Call(method, executableService) {
        if (method == "Run" || method == "") {
            result := this.Run(executableService)
            if (result == "") {
                return true
            }
            return result
        }
    }

    Run(executableService) {
        throw "Not implemented"
    }

    SetDescription(description) {
        this.description := description
        return this
    }

    GetDescription() {
        return this.description
    }

    AddTags(tags) {
        EnsureArray(tags)
        for i, tag in tags {
            this.tags.Push(tag)
        }
        return this
    }
}