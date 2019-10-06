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
        userOptions := nextCommand.CanRunWithUser(currentUser)
        if (userOptions.block) {
            reason := "Command """ nextCommand.GetDescription() """"
            reason .= "`ncannot be run for user """ currentUser """."
            mainController.BlockNextCommand(reason)
            return
        }
        if (userOptions.HasKey("switchTo")) {
            desktop := Flip(this._desktopToUserMap)[userOptions.switchTo]
            desktopChange := new ChangeDesktop(desktop)
            mainController.RunCommand(desktopChange, { caller: this })
        }
        if (userOptions.HasKey("runAs")) {
            userChange := new ChangeEnvironment({ user: userOptions.runAs })
            mainController.RunCommand(userChange, { caller: this })
        }
    }
}
