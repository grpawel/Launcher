#Include %A_ScriptDir%\src\Commands\Command.ahk

; Show message within gui.
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

    Run(controller) {
        if (this._options.disablePrevious) {
            controller.GetGui().DisableAll()
        }
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
