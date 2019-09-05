#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\MultipleUsersExtension.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\DesktopsExtension.ahk

RegisterExtensions(mainController) {
    MultipleUsersExtension(mainController)
    DesktopsExtension(mainController)
}