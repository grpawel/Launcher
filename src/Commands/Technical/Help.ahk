#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Commands\Executable.ahk

class Help extends Command {
    description := "Show/hide help"
    tags := ["technical"]
    doesNeedGui := true

    _keyPressSubscription :=
    _commandDeactivatedSubscription :=

    Run(mainController) {
        global eventBus
        activeCommand := mainController.GetActiveCommand()
        if (!activeCommand.isHelpOpened) {
            activeCommand.isHelpOpened := true
            this._keyPressSubscription := eventBus.Subscribe("keyPressed", this._OnKeyPressed.Bind(this, activeCommand.commands), "HELP")
            this._commandDeactivatedSubscription := eventBus.SubscribeOnce("CommandDeactivated", this._OnCommandDeactivated.Bind(this))
            GuiShowListView()
        } else {
            command.isHelpOpened := false
            GuiRemoveListView()
            eventBus.Unsubscribe(this._keyPressSubscription)
            eventBus.Unsubscribe(this._commandDeactivatedSubscription)
        }
        GuiSetInput("")
    }

    _OnKeyPressed(commands, input) {
        rows := []
        for key, value in commands {
            description := value.GetDescription()
            if (StartsWith(key, input)) {
                rows.Push([key, description])
            }
        }
        GuiRemoveRowsListView()
        GuiPopulateListView(rows)
    }

    _OnCommandDeactivated(previousCommand) {
        previousCommand.isHelpOpened := false
        GuiRemoveListView()
    }
}
