#Include %A_ScriptDir%\src\Executables\CommandSet\Command.ahk
#Include %A_ScriptDir%\src\Executables\Executable.ahk

class Help extends Command {
    description := "Show/hide help"
    tags := ["technical"]

    Run(mainController) {
        currentExecutable := mainController.GetCurrentExecutable()
        isActive := currentExecutable.base.__Class == "HelpExecutable"
        if (!isActive) {
            this._originalExecutable := currentExecutable
            helpWrapper := new HelpExecutable(this._originalExecutable)
            mainController.ChangeExecutable(helpWrapper)
            GuiShowListView()
        } else {
            GuiRemoveListView()
            mainController.ChangeExecutable(this._originalExecutable)
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

    Execute(input, mainController) {
        this._Populate(input)
        return this._commandSet.Execute(input, mainController)
    }

    _Populate(input) {
        rows := []
        for key, value in this._commandSet.commands {
            description := value.GetDescription()
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