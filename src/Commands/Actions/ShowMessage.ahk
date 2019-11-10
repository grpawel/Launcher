#Include %A_ScriptDir%\src\Commands\Command.ahk

; Show message within gui.
; `message` can be string or function object.
; If calling `message` returns anything other than empty string, the returned value is shown.
; `message` is called with controller and context.
; Options:
; "textColor": color of text message. If not given default one from Gui is used.
; "disablePrevious": disable previous inputs in Gui. Default is false.
class ShowMessage extends Command {
    static DEFAULT_OPTIONS := { disablePrevious: false }

    __New(message, options = "") {
        this._message := message
        this._description := "Show message """ message """"
        static V := new ValidatorFactory()
        static VAL := V.Object({ "textColor": V.String()
                               , "disablePrevious": V.Boolean() }
                               , { ignoreMissing: true, noOtherKeys: true })
        this._options := MergeArrays(this.DEFAULT_OPTIONS, options)
        VAL.ValidateAndShow(this._options)
    }

    Run(contr) {
        if (this._options.disablePrevious) {
            contr.GetGui().DisableAll()
        }
        message := GetValue(this._message, contr, context)
        controlOptions := { text: message }
        if (this._options.textColor != "") {
            controlOptions.textColor := this._options.textColor
            controlOptions.textColorDisabled := this._options.textColor
        }
        contr.GetGui().AddText(controlOptions)
        contr.GetGui().Show()
    }

    DoesNeedGui() {
        return true
    }
}
