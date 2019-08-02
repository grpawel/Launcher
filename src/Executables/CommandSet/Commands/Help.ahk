#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk
#Include %A_ScriptDir%\src\Executables\Executable.ahk

class Help extends Command {
    __New() {
        this._active := false
    }
    Run() {
        global executableService
        currentExecutable := executableService.GetCurrentExecutable()
        if (this._active) {
            GuiRemoveListView()
            executableService.ChangeExecutable(this._originalExecutable)
            this._active := false
        } else {
            this._originalExecutable := currentExecutable
            helpWrapper := new HelpExecutable(this._originalExecutable)
            executableService.ChangeExecutable(helpWrapper)
            GuiShowListView()
            this._active := true
        }
        GuiSetInput("")
        return false
    }
}

class HelpExecutable extends Executable {
    subscribedTo := ["keyPressed", "returnPressed", "rowDoubleClicked"]

    __New(commandSet) {
        this._commandSet := commandSet
    }

    Execute(input) {
        this._Populate(input)
        return this._commandSet.Execute(input)
    }

    _Populate(input) {
        rows := []
        for key, value in this._commandSet.commands {
            description := value.GetTitle()
            ;if (description == "") {
                ;description := value ""
            ;}
            if (StartsWith(key, input)) {
                rows.Push([key, description])
            }
        }
        GuiRemoveRowsListView()
        GuiPopulateListView(rows)
    }

    OnBeforeExecutableChanged() {
        GuiRemoveListView()
    }
}