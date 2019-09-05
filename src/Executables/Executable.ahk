class Executable {
    title := ""

    ; possible values: ["keyPressed", "returnPressed", "rowDoubleClicked"]
    subscribedTo := []

    Execute(input, executableService) {
        return false
    }

    GetTitle() {
        return this.title
    }

    OnBeforeExecutableChanged() {
    }
}