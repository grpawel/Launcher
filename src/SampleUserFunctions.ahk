#Include %A_ScriptDir%\src\Utils\CommandUtils.ahk

UserFunctions(mainController) {
    desktops := { 2: "dev" }
    userSetter := new SetUserFromDesktop()
    mainController.GetGui().SubscribeGuiShowing(BindControllerToCommand(userSetter, mainController))
}