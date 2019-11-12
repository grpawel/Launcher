#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk
#Include %A_ScriptDir%\src\Commands\ScriptInteraction\ChangeEnvironment.ahk

; Changes user in environment to user configured in next command.
; Intended to subscribe to `commandAboutToRun` from controller.
class SetUserFromUserConfig extends Command {
    _description := "Set user from command config"

    Run(contr, context) {
        com := context.event.payload.nextCommand
        config := com.GetUserConfig()
        if (!config.HasKey("runAs")) {
            return
        }
        user := config.runAs
        userChange := new ChangeEnvironment({ settings: { "user": user } }, "untilGuiDestroyed")
        contr.RunCommand(userChange)
    }
}
