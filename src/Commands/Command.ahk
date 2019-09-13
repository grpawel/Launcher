class Command {
    description := ""
    tags := []
    doesNeedGui {
        get {
            return false
        }
    }

    __Call(method, mainController, context="") {
        if (method == "Run" || method == "") {
            this.Run(mainController, context)
        }
    }

    Run(mainController, context="") {
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
