class Command {
    _description := ""
    _tags := []

    __Call(method, mainController, context="") {
        if (method == "Run" || method == "") {
            this.Run(mainController, context)
        }
    }

    Run(mainController, context="") {
        throw "Not implemented"
    }

    SetDescription(description) {
        this._description := description
        return this
    }

    GetDescription() {
        return this._description
    }

    AddTags(tags) {
        EnsureArray(tags)
        for i, tag in tags {
            this._tags.Push(tag)
        }
        return this
    }

    GetTags() {
        return this._tags
    }

    DoesNeedGui() {
        return false
    }
}
