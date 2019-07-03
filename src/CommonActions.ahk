open(param) {
    run, %param%
}

reload(param) {
    Reload
}

enter(param) {
    global currentList
    currentList := param
    global level := level + 1
    GuiAddInput("eachKey")
    return [false, "next command"]
}

search(searchObject) {
    global currentList
    currentList := searchObject
    global level := level + 1
    GuiAddInput("onlyEnter")
    return [false, "next command"]
}

class WebSearch extends BaseCommandSet {
    __New(urlTemplate, title) {
        this._urlTemplate := urlTemplate
        this.title := title
    }
    Execute(query) {
        url := StrReplace(this._urlTemplate, "REPLACEME", query)
        run, %url%
        return [true]
    }
}
