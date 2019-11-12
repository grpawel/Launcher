#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\Commands\Actions\ChangeDesktop.ahk

; Change desktop to one associated with user from command config.
; Intended to subscribe to `commandAboutToRun` from controller,
; so the command will be run on correct desktop.
;
; Requires DesktopsExtension to be active.
class ChangeDesktopFromUserConfig extends Command {
    Run(contr, context) {
        com := context.event.payload.nextCommand
        config := com.GetUserConfig()
        if (!config.HasKey("switchTo")) {
            return
        }
        user := contr.GetEnvironment().GetSetting("user")
        switchFromCurrentUser := config.switchFrom == ""
                                || config.switchFrom == "all"
                                || ArrayContains(config.switchFrom, user)
        if (switchFromCurrentUser) {
            desktopToUserMap := contr.GetExtension("users").GetDesktopToUserMap()
            desktop := Flip(desktopToUserMap)[config.switchTo]
            desktopChange := new ChangeDesktop(desktop)
            contr.RunCommand(desktopChange)
        }
    }
}
