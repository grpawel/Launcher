#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

; Shows help for  CommandSet given in constructor, or if not
; then one calling this help.
class Help extends Command {
    _description := "Show/hide help"

    __New(commandSet = "") {
        this._commandSet := commandSet
        this.AddTags(["technical"])
    }

    Run(mainController, context) {
        helped := this._commandSet != "" ? this._commandSet : context.caller
        if (helped._helpAttachment == "") {
            ; Because instance of this command can be added to multiple CommandSets
            ; and one CommandSet can have multiple Help commands available
            ; we cannot store any data within this object
            ; so we attach it to calling CommandSet object
            ; then any of Help objects can use the same data and eg. toggle visibility
            helped._helpAttachment := new this._HelpAttachment(mainController, helped)
            helped._helpAttachment.AttachAndShow()
        } else {
            if (helped._helpAttachment.state != "shown") {
                helped._helpAttachment.Show()
            } else {
                helped._helpAttachment.Hide()
            }
        }
        helped.GetGuiControl().SetText("")
    }

    DoesNeedGui() {
        return true
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
        state := "detached"

        __New(mainController, commandSet) {
            this._mainController := mainController
            this._commandSet := commandSet
        }

        AttachAndShow() {
            this._SubscribeWhenToDetach()
            this._guiControl := this._mainController.GetGui().AddListView()
            this._SubscribeInput()
            this.state := "shown"
        }

        Show() {
            this._SubscribeInput()
            this._guiControl.Show()
            this.state := "shown"
        }

        Hide() {
            this.state := "hidden"
            this._UnsubscribeInput()
            this._guiControl.Hide()
        }

        _Detach() {
            if (this.state != "detached") {
            this.state := "detached"
            this._UnsubscribeWhenToDetach()
            this._commandSet._helpAttachment := ""
        }
        }

        _OnInputChanged(input) {
            this._guiControl.RemoveRows()
            commands := this._commandSet.GetCommands()
            rows := []
            for key, value in commands {
                if (input == "" || StartsWith(key, input)) {
                description := value.GetDescription()
                    rows.Push([key, description])
                }
            }
            this._guiControl.Populate(rows)
        }

        _OnRowDoubleClicked(key) {
            this._commandSet.GetGuiControl().SetText(key)
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

        _SubscribeWhenToDetach() {
            this._nextCommandRunningSubscription := this._mainController.SubscribeCommandAboutToRun(this._OnNextCommandRunned.Bind(this))
            this._guiClosingSubscription := this._mainController.GetGui().SubscribeGuiClosing(this._Detach.Bind(this))
        }

        _SubscribeInput() {
            this._inputChangedSubscription := this._commandSet.GetGuiControl().SubscribeInputChanged(this._OnInputChanged.Bind(this))
            this._rowDoubleClickedSubscription := this._guiControl.SubscribeRowSelected(this._OnRowDoubleClicked.Bind(this))
        }

        _UnsubscribeInput() {
            this._inputChangedSubscription.Unsubscribe()
            this._rowDoubleClickedSubscription.Unsubscribe()
        }

        _UnsubscribeWhenToDetach() {
            this._nextCommandRunningSubscription.Unsubscribe()
            this._guiClosingSubscription.Unsubscribe()
        }
    }
}
