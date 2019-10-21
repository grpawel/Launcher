class Command {
    _description := ""
    _tags := []

    Run(controller, context="") {
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

    ; Methods used in internals, e.g. in Help.
    SetPayload(key, payload) {
        if (!this.HasKey("_payload")) {
            this._payload := {}
        }
        this._payload[key] := payload
    }

    GetPayload(key) {
        return this._payload[key]
    }

    ; Workaround for `com.__Class` not working with `MethodDecorator`
    GetCommandName() {
        return this.__Class
    }
}
