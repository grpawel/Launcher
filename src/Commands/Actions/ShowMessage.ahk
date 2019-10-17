#Include %A_ScriptDir%\src\Commands\Command.ahk

; Show message within gui.
; Options:
; "textColor": color of text message. If not given default one from Gui is used.
class ShowMessage extends Command {
    __New(message, options = "") {
        this._message := message
        this._description := "Show message """ message """"
        static V := new ValidatorFactory()
        static VAL := V.Or([ V.Empty()
                           , V.Object({ "textColor": V.String() }
                                     , { ignoreMissing: true, noOtherKeys: true }) ])
        VAL.ValidateAndShow(options)
        this._options := options
    }

    Run(controller) {
        controller.GetGui().DisableAll()
        controlOptions := { text: this._message }
        if (this._options.textColor != "") {
            controlOptions.textColor := this._options.textColor
            controlOptions.textColorDisabled := this._options.textColor
        }
        controller.GetGui().AddText(controlOptions)
        controller.GetGui().Show()
    }

    DoesNeedGui() {
        return true
    }
}
