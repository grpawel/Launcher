#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

; Shows help for  CommandSet given in constructor, or if not
; then one calling this help.
class Help extends Command {
    description := "Show/hide help"
    tags := ["technical"]
    doesNeedGui := true

    __New(commandSet = "") {
        this._commandSet := commandSet
    }

    Run(mainController, caller) {
        commandSet := this._commandSet != "" ? this._commandSet : caller
        if (commandSet._helpAttachment == "") {
            ; Because instance of this command can be added to multiple CommandSets
            ; and one CommandSet can have multiple Help commands available
            ; we cannot store any data within this object
            ; so we attach it to calling CommandSet object
            ; then any of Help objects can use the same data and eg. toggle visibility
            commandSet._helpAttachment := new this._HelpAttachment(mainController, commandSet)
            commandSet._helpAttachment.AttachAndShow()
        } else {
            if (!commandSet._helpAttachment.isOpened) {
                commandSet._helpAttachment.Show()
            } else {
                commandSet._helpAttachment.Hide()
            }
        }
        commandSet.GetGuiControl().SetText("")
    }

    ; There are three possible states:
    ; (D) Detached: user has not opened help yet, closed GUI or opened another CommandSet
    ; (S) Shown: subscribed to user input and command selection; attached to CommandSet
    ; (H) Hidden: attached to CommandSet
    ;
    ; Possible transitions between those states:
    ; (CurrentState), event -> (NextState)
    ; (D), Help.Run() called -> (S)
    ; (S), Help.Run() called -> (H)
    ; (H), Help.Run() called -> (S)
    ; (S/H), command selected -> (D)
    ; (S/H), GUI closed -> (D)
    class _HelpAttachment {
        isOpened := false

        __New(mainController, commandSet) {
            this._mainController := mainController
            this._commandSet := commandSet
        }

        AttachAndShow() {
            this._SubscribeWhenDetach()
            this._SubscribeInput()
            this._guiControl := this._mainController.GetGui().AddListView()
            this.isOpened := true
        }

        Show() {
            this._SubscribeInput()
            this._guiControl.Show()
            this.isOpened := true
        }

        Hide() {
            this.isOpened := false
            this._UnsubscribeInput()
            this._guiControl.Hide()
        }

        _Detach() {
            if (this.isOpened) {
                this._UnsubscribeInput()
            }
            this._UnsubscribeWhenDetach()
            this._guiControl.Hide()
            this._commandSet._helpAttachment := ""
        }

        _OnInputChanged(input) {
            commands := this._commandSet.commands
            rows := []
            for key, value in this._commandSet.commands {
                description := value.GetDescription()
                if (StartsWith(key, input)) {
                    rows.Push([key, description])
                }
            }
            this._guiControl.RemoveRows()
            this._guiControl.Populate(rows)
        }

        _OnNextCommandRunned(context) {
            if (context.nextCommand.base.__Class == "Help") {
                ; nextCommand could be user trying to close help.
                ; If we call Detach() here,
                ; Help.Run() would not see the attachment and would create help again.
            } else {
                this._Detach()
            }
        }

        _SubscribeWhenDetach() {
            this._commandSelectedSubscription := this._commandSet.SubscribeBeforeNextCommandRunned(this._OnNextCommandRunned.Bind(this))
            this._guiClosedSubscription := this._mainController.GetGui().SubscribeGuiClosed(this._Detach.Bind(this))
        }

        _SubscribeInput() {
            this._inputChangedSubscription := this._commandSet.GetGuiControl().SubscribeInputChanged(this._OnInputChanged.Bind(this))
        }

        _UnsubscribeInput() {
            this._inputChangedSubscription.Unsubscribe()
        }

        _UnsubscribeWhenDetach() {
            this._commandSelectedSubscription.Unsubscribe()
            this._guiClosedSubscription.Unsubscribe()
        }
    }
}
