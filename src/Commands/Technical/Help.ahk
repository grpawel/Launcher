#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Commands\Executable.ahk

class Help extends Command {
    description := "Show/hide help"
    tags := ["technical"]

    Run(mainController) {
        activeCommand := mainController.GetActiveCommand()
        isActive := activeCommand.base.__Class == "HelpExecutable"
        if (!isActive) {
            this._originalCommand := activeCommand
            helpWrapper := new HelpExecutable(this._originalCommand)
            mainController.SetActiveCommand(helpWrapper)
            GuiShowListView()
        } else {
            GuiRemoveListView()
            mainController.SetActiveCommand(this._originalCommand)
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

    Deactivate() {
        GuiRemoveListView()
    }
}