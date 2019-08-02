class Executable {

    ; possible values: ["keyPressed", "returnPressed", "rowDoubleClicked"]
    subscribedTo := []

    Execute(input) {
        return false
    }

    OnBeforeExecutableChanged() {
    }
}