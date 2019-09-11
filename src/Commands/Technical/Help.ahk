#Include %A_ScriptDir%\src\Commands\Command.ahk

class Help extends Command {
    description := "Show/hide help"
    tags := ["technical"]
    doesNeedGui := true

    _keyPressSubscription :=
    _commandDeactivatedSubscription :=

    Run(mainController, caller) {
        global globalEventBus
        if (!caller.isHelpOpened) {
            caller.isHelpOpened := true
            guiControl := mainController.GetGui().AddListView()
            this._keyPressSubscription := globalEventBus.Subscribe("keyPressed", this._OnKeyPressed.Bind(this, guiControl, caller.commands))
            this._commandDeactivatedSubscription := globalEventBus.SubscribeOnce("CommandDeactivated", this._OnCommandDeactivated.Bind(this, guiControl))
        } else {
            caller.isHelpOpened := false
            ; GuiRemoveListView()
            this._keyPressSubscription.Unsubscribe()
            this._commandDeactivatedSubscription.Unsubscribe()
        }
        ;GuiSetInput("")
    }

    _OnKeyPressed(guiControl, commands, input) {
        rows := []
        for key, value in commands {
            description := value.GetDescription()
            if (StartsWith(key, input)) {
                rows.Push([key, description])
            }
        }
        guiControl.RemoveRows()
        guiControl.Populate(rows)
    }

    _OnCommandDeactivated(guiControl, previousCommand) {
        previousCommand.isHelpOpened := false
        guiControl.Hide()
    }
}
