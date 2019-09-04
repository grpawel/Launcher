#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\MultipleUsersExtension.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\DesktopsExtension.ahk

RegisterExtensions(executableService) {
    MultipleUsersExtension(executableService)
    DesktopsExtension(executableService)
}