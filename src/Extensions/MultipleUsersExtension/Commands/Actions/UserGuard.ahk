#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

; Checks if command and current user match.
class UserGuard extends Command {
    Run(mainController, context) {
        nextCommand := context.nextCommand
        allowedUsers := nextCommand.GetAllowedUsers()
        if (allowedUsers == "") {
            ; Suppose all users are OK. Nothing to block.
            return
        }
        currentUser := mainController.GetEnvironment()["user"]
        if (ArrayContains(allowedUsers, currentUser)) {
            ; Current user is on an allowance list. Nothing to block.
            return
        } 
        reason := "Command """ nextCommand.GetDescription() """"
        reason .= "`ncan only be run for users [" . Join(allowedUsers, ",") . "]" 
        reason .= "`nbut current user is """ currentUser """."
        blocker := new ChangeEnvironment({ Open: new BlockingOpener(reason) }, "untilGuiClosed")
        mainController.NotifyCommandAboutToRun(blocker)
        %blocker%(mainController, { caller: this })
    }
}
