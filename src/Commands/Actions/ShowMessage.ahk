#Include %A_ScriptDir%\src\Commands\Command.ahk

; Show message within gui.
; `message` can be string or function object.
; If calling `message` returns anything other than empty string, the returned value is shown.
; `message` is called with controller and context.
; Options:
; "textColor": color of text message. If not given default one from Gui is used.
class ShowMessage extends Command {
    __New(message, options = "") {
        this._message := message
        this._description := "Show message """ message """"
        static V := new ValidatorFactory()
        static VAL := V.Object({ "textColor": V.String() }
                              , { allowMissingKeys: true
                                , allowOtherKeys: false
                                , allowEmptyVariable: true })
        this._options := options
        VAL.ValidateAndShow(this._options)
    }

    Run(contr) {
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
