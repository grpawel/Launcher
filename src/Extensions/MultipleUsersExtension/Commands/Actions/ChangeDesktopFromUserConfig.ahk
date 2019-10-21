#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk


class ChangeDesktopFromUserConfig extends Command {
    __New(desktopToUserMap) {
        this._desktopToUserMap := desktopToUserMap
    }

    Run(contr, context) {
        com := context.event.payload.nextCommand
        config := com.GetUserConfig()
        if (!config.HasKey("switchTo")) {
            return
        }
        user := contr.GetEnvironment()["user"]
        switchFromCurrentUser := config.switchFrom == ""
                                || config.switchFrom == "all"
                                || ArrayContains(config.switchFrom, user)
        if (switchFromCurrentUser) {
            desktop := Flip(this._desktopToUserMap)[config.switchTo]
            desktopChange := new ChangeDesktop(desktop)
            contr.RunCommand(desktopChange)
        }
    }
}
