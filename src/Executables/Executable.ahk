class Executable {
    title := ""

    ; possible values: ["keyPressed", "returnPressed", "rowDoubleClicked"]
    subscribedTo := []

    Execute(input, mainController) {
        return false
    }

    GetTitle() {
        return this.title
    }

    OnBeforeExecutableChanged() {
    }
}