#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

; Shows help for  CommandSet given in constructor, or if not
; then one calling this help.
class Help extends Command {
    _description := "Show/hide help"

    __New(commandSet = "") {
        this._commandSet := commandSet
    }

    Run(controller, context) {
        helped := this._commandSet != "" ? this._commandSet : context.caller
        attachment := helped.GetPayload("helpAttachment")
        if (attachment == "") {
            ; Because instance of this command can be added to multiple CommandSets
            ; and one CommandSet can have multiple Help commands available
            ; we cannot store any data within this object
            ; so we attach it to calling CommandSet object
            ; then any of Help objects can use the same data and eg. toggle visibility
            attachment := new this._HelpAttachment(controller, helped)
            attachment.AttachAndShow()
            helped.SetPayload("helpAttachment", attachment)
        } else {
            if (attachment.state != "shown") {
                attachment.Show()
            } else {
                attachment.Hide()
            }
        }
        helped.GetGuiControl().SetText("")
    }

    DoesNeedGui() {
        return true
    }

    UsesExistingControl() {
        return true
    }

    ; There are three possible states:
    ; (D) Detached: user has not opened help yet, user opened another CommandSet or GUI is destroyed.
    ; (S) Shown: subscribed to user input and command selection; attached to CommandSet
    ; (H) Hidden: attached to CommandSet
    ;
    ; Possible transitions between those states:
    ; (CurrentState), event -> (NextState)
    ; (D), Help.Run() called -> (S)
    ; (S), Help.Run() called -> (H)
    ; (H), Help.Run() called -> (S)
    ; (S/H), command set not active -> (D)
    class _HelpAttachment {
        state := "detached"

        __New(controller, commandSet) {
            this._controller := controller
            this._commandSet := commandSet
        }

        AttachAndShow() {
            this._SubscribeCommandSetNotActive()
            this._guiControl := this._controller.GetGui().AddListView({position: "right", width: 300})
            this._SubscribeInput()
            this._controller.GetGui().Show()
            this.state := "shown"
        }

        Show() {
            this._SubscribeInput()
            this._guiControl.Show()
            this._controller.GetGui().Show()
            this.state := "shown"
        }

        Hide() {
            this.state := "hidden"
            this._UnsubscribeInput()
            this._guiControl.Hide()
            this._controller.GetGui().Show()
        }

        _Detach() {
            if (this.state != "detached") {
                this.state := "detached"
                this._guiControl.Disable()
                this._UnsubscribeCommandSetNotActive()
                this._UnsubscribeInput()
                this._commandSet.SetPayload("helpAttachment", "")
            }
        }

        _OnInputChanged(input) {
            this._guiControl.RemoveRows()
            commands := this._commandSet.GetAll()
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

        _UnsubscribeCommandSetNotActive() {
            this._commandSetDisabledSubscription.Unsubscribe()
        }

        _SubscribeCommandSetNotActive() {
            this._commandSetDisabledSubscription := this._commandSet.SubscribeNotActive(this._Detach.Bind(this))
        }

        _SubscribeInput() {
            this._inputChangedSubscription := this._commandSet.GetGuiControl().SubscribeInputChanged(this._OnInputChanged.Bind(this))
            this._rowDoubleClickedSubscription := this._guiControl.SubscribeRowSelected(this._OnRowDoubleClicked.Bind(this))
        }

        _UnsubscribeInput() {
            this._inputChangedSubscription.Unsubscribe()
            this._rowDoubleClickedSubscription.Unsubscribe()
        }
    }
}
