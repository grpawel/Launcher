#Include %A_ScriptDir%\src\Extensions\MultipleUsersExtension\MultipleUsersExtension.ahk
#Include %A_ScriptDir%\src\Extensions\DesktopsExtension\DesktopsExtension.ahk

class ExtensionManager {
    _extensions :=  [ new MultipleUsersExtension()
                    , new DesktopsExtension() ]

    RegisterExtensions() {
        for i, extension in this._extensions {
            extension.Register()
        }
    }

    Attach(controller, settings = "") {
        for i, extension in this._extensions {
            extensionSettings := settings[extension.name]
            extension.Attach(controller, extensionSettings)
        }
    }
}
