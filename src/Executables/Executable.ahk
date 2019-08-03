class Executable {
    title := ""

    ; possible values: ["keyPressed", "returnPressed", "rowDoubleClicked"]
    subscribedTo := []

    Execute(input) {
        return false
    }

    GetTitle() {
        return this.title
    }

    OnBeforeExecutableChanged() {
    }
}