class Command {
    description := ""
    tags := []
    doesNeedGui := false

    __Call(method, mainController, caller="") {
        if (method == "Run" || method == "") {
            this.Run(mainController, caller)
        }
    }

    Run(mainController) {
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
