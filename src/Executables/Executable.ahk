class Executable extends Command {
    title := ""

    ; possible values: ["keyPressed", "returnPressed", "rowDoubleClicked"]
    subscribedTo := []

    ; Activate is called when this command is set as active.
    Activate(mainController) {
    }

    ; Deactivate is called when another command is set as active, before activation of next command.
    Deactivate(mainController) {
    }

    Execute(input, mainController) {
        return false
    }

    GetTitle() {
        return this.title
    }
}