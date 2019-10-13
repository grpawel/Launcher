#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk

; Checks if command and current user match.
class UserGuard extends Command {
    __New(desktopToUserMap) {
        this._desktopToUserMap := desktopToUserMap
    }

    Run(controller, context) {
        nextCommand := context.nextCommand
        currentUser := controller.GetEnvironment()["user"]
        userOptions := nextCommand.CanRunWithUser(currentUser)
        if (userOptions.HasKey("switchTo")) {
            desktop := Flip(this._desktopToUserMap)[userOptions.switchTo]
            desktopChange := new ChangeDesktop(desktop)
            controller.RunCommand(desktopChange, { caller: this })
        }
        if (userOptions.HasKey("runAs")) {
            userChange := new ChangeEnvironment({ user: userOptions.runAs })
            controller.RunCommand(userChange, { caller: this })
        }
    }
}

MultipleUsers_IsUserAllowed(com, contr) {
    currentUser := contr.GetEnvironment()["user"]
    if (com.CanRunWithUser(currentUser).block) {
        return "Command """ com.GetDescription() """ `ncannot be run for user """ currentUser """."
    } else {
        return false
    }
}
