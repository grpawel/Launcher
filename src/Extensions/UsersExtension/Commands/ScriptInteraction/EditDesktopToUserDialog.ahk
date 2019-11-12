#Include %A_ScriptDir%\src\Commands\Command.ahk

; Edit associations between users and dialogs.
; Affects only calling controller.
; TODO make it persistent between reloads
class EditDesktopToUserDialog extends Command {
    _description := "Edit desktop to user associations"

    Run(contr, context) {
        desktopToUserMap := contr.GetExtension("users").GetDesktopToUserMap()
        gui := contr.GetGui()
        userInputs := []
        totalDesktops := GetTotalDesktopsFunction()
        for desktop in Range(1, totalDesktops + 1) {
            gui.AddText({ text: "Desktop " desktop })
            input := gui.AddTextInput()
            user := desktopToUserMap[desktop]
            input.SetText(user)
            userInputs[desktop] := input
        }
        gui.SubscribeReturnPressed(this._OnReturnPressed.Bind(this, contr, userInputs))
        gui.Show()
    }

    _OnReturnPressed(contr, userInputs) {
        newMap := {}
        for desktop, input in userInputs {
            newMap[desktop] := input.GetText()
            input.Disable()
        }
        contr.GetGui().Destroy()
        contr.GetExtension("users").SetDesktopToUserMap(newMap)
    }

    DoesNeedGui() {
        return true
    }
}
