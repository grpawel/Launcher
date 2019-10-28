#Include %A_ScriptDir%\src\Events\CommandToSubscriber.ahk

UserFunctions(controller) {
    desktops := { 2: "dev" }
    userSetter := new SetUserFromDesktop()
    controller.SubscribeRootCommandAboutToRun(CommandToSubscriber(userSetter, controller))
}
