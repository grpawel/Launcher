open(param) {
    run, %param%
}

reload(param) {
    Reload
}

enter(newExecutable) {
    global currentExecutable := newExecutable
    global level := level + 1
    GuiAddInput("eachKey")
    return false
}

search(searchExecutable) {
    global currentExecutable := searchExecutable
    global level := level + 1
    GuiAddInput("onlyEnter")
    return false
}

class WebSearch extends Executable {
    __New(urlTemplate, title) {
        this._urlTemplate := urlTemplate
        this.title := title
    }
    Execute(query) {
        url := StrReplace(this._urlTemplate, "REPLACEME", query)
        run, %url%
        return true
    }
}
