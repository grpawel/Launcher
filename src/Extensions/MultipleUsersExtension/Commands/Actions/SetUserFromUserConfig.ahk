#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\ChangeEnvironment.ahk


class SetUserFromUserConfig extends Command {
    __New(desktopToUserMap) {
        this._desktopToUserMap := desktopToUserMap
    }

    Run(contr, context) {
        com := context.nextCommand
        config := com.GetUserConfig()
        if (!config.HasKey("runAs")) {
            return
        }
        user := config.runAs

        userChange := new ChangeEnvironment({"user": user}, "untilGuiDestroyed")
        contr.RunCommand(userChange)
    }
}
