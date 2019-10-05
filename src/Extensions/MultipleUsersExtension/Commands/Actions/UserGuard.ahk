#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk

; Checks if command and current user match.
class UserGuard extends Command {
    __New(desktopToUserMap) {
        this._desktopToUserMap := desktopToUserMap
    }

    Run(mainController, context) {
        nextCommand := context.nextCommand
        currentUser := mainController.GetEnvironment()["user"]
        isAllowed := nextCommand.CanRunWithUser(currentUser)
        if (isAllowed == true) {
            ; nothing to block
            return
        }
        if (isAllowed == false) {
            reason := "Command """ nextCommand.GetDescription() """"
            reason .= "`ncannot be run for user """ currentUser """."
            mainController.BlockNextCommand(reason)
            return
        }
        if (isAllowed.switchTo != "") {
            desktop := Flip(this._desktopToUserMap)[isAllowed.switchTo]
            switcher := new ChangeDesktop(desktop)
            mainController.RunCommand(switcher, { caller: this })
            return
        }
    }
}
