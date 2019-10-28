#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\ChangeEnvironment.ahk

; Changes user in environment to user configured in next command.
; Intended to subscribe to `commandAboutToRun` from controller.
class SetUserFromUserConfig extends Command {
    __New(desktopToUserMap) {
        this._desktopToUserMap := desktopToUserMap
    }

    Run(contr, context) {
        com := context.event.payload.nextCommand
        config := com.GetUserConfig()
        if (!config.HasKey("runAs")) {
            return
        }
        user := config.runAs
        userChange := new ChangeEnvironment({"user": user}, "untilGuiDestroyed")
        contr.RunCommand(userChange)
    }
}
