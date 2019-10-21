#Include %A_ScriptDir%\src\Utils\CommandUtils.ahk

UserFunctions(controller) {
    desktops := { 2: "dev" }
    userSetter := new SetUserFromDesktop()
    controller.SubscribeRootCommandAboutToRun(CommandAsSubscriber(userSetter, controller))
}
