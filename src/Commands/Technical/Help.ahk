#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

class Help extends Command {
    description := "Show/hide help"
    tags := ["technical"]
    doesNeedGui := true

    _keyPressSubscription :=
    _commandDeactivatedSubscription :=

    Run(mainController, caller) {
        global globalEventBus
        if (caller._helpAttachment == "") {
            ; Because instance of this command can be added to multiple CommandSets
            ; and one CommandSet can have multiple Help commands available
            ; we cannot store any data within this object
            ; so we attach it to calling CommandSet object
            ; then any of Help objects can use the same data and eg. toggle visibility
            caller._helpAttachment := {}
        }
        if (!caller._helpAttachment.isOpened) {
            caller._helpAttachment.isOpened := true
            if (caller._helpAttachment.guiControl == "") {
                caller._helpAttachment.guiControl := mainController.GetGui().AddListView()
            } else {
                caller._helpAttachment.guiControl.Show()
            }
            caller._helpAttachment.keyPressSubscription := globalEventBus.Subscribe("keyPressed", this._OnKeyPressed.Bind(this, caller._helpAttachment.guiControl, caller.commands))
            caller._helpAttachment.commandDeactivatedSubscription := globalEventBus.SubscribeOnce("CommandDeactivated", this._OnCommandDeactivated.Bind(this, guiControl))
        } else {
            caller._helpAttachment.isOpened := false
            caller._helpAttachment.guiControl.Hide()
            caller._helpAttachment.keyPressSubscription.Unsubscribe()
            caller._helpAttachment.commandDeactivatedSubscription.Unsubscribe()
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
