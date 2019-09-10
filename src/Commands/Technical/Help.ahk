#Include %A_ScriptDir%\src\Commands\Command.ahk

class Help extends Command {
    description := "Show/hide help"
    tags := ["technical"]
    doesNeedGui := true

    _keyPressSubscription :=
    _commandDeactivatedSubscription :=

    Run(mainController) {
        global globalEventBus
        activeCommand := mainController.GetActiveCommand()
        if (!activeCommand.isHelpOpened) {
            activeCommand.isHelpOpened := true
            this._keyPressSubscription := globalEventBus.Subscribe("keyPressed", this._OnKeyPressed.Bind(this, activeCommand.commands), "HELP")
            this._commandDeactivatedSubscription := globalEventBus.SubscribeOnce("CommandDeactivated", this._OnCommandDeactivated.Bind(this))
            GuiShowListView()
        } else {
            command.isHelpOpened := false
            GuiRemoveListView()
            globalEventBus.Unsubscribe(this._keyPressSubscription)
            globalEventBus.Unsubscribe(this._commandDeactivatedSubscription)
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
