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

    UsesExistingControl() {
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

    ; Returns shallow copy of command.
    ; Extending classes that add object data must override this method and clone the data themselves.
    Duplicate() {
        duplicate.base := this.base
        duplicate := ObjClone(this)
        duplicate._tags := ObjClone(this._tags)
        if (this.HasKey("_payload")) {
            for key, value in this._payload {
                duplicate._payload[key] := ObjClone(value)
            }
        }
        return duplicate
    }

    ; Workaround for `com.__Class` not working with `MethodDecorator`
    GetCommandName() {
        return this.__Class
    }
}
