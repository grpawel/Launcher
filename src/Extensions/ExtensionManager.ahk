
class ExtensionManager {
    static _EXTENSION_CLASSES := {}

    ; (static)
    ; Enables extension to be activated with a controller.
    RegisterExtension(extClass) {
        name := extClass.NAME
        ExtensionManager._EXTENSION_CLASSES[name] := extClass
    }

    __New(contr) {
        this._controller := contr
        this._extensions := {}
    }

    ; Attach extensions to given controller.
    ; Each controller gets its own extension objects.
    ; If extension is not attached, its functions are not used with given controller.
    ; `extensionNames` (string[] | "all") - extensions to use
    ; `settings` - extension specific settings
    ; Examples:
    /*
    extensionManager.Activate(contr, "all", { ext1: { setting1: "abc" }, ext2: { setting: "def" } })
    extensionManager.Activate(contr, ["ext1"], { ext1: { setting1: "abc" } })
    */
    Activate(extensionNames, settings = "") {
        names := this._GetExtensionNames(extensionNames)
        for i, name in names {
            extClass := ExtensionManager._EXTENSION_CLASSES[name]
            this._extensions[name] := new extClass()
        }
        for name, ext in this._extensions {
            extSettings := settings[name]
            ext.Attach(this._controller, extSettings)
        }
    }

    GetExtension(extensionName) {
        return this._extensions[extensionName]
    }

    _GetExtensionNames(extensionNames) {
        if (extensionNames == "all") {
            return Keys(ExtensionManager._EXTENSION_CLASSES)
        } else {
            return extensionNames
        }
    }
}
