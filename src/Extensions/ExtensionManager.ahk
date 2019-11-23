
class ExtensionManager {
    static _EXTENSION_CLASSES := {}

    ; (static)
    ; Enables extension to be activated with a controller.
    ; `extClass` - extension class object.
    RegisterExtension(extClass) {
        name := extClass.NAME
        ExtensionManager._EXTENSION_CLASSES[name] := extClass
    }

    __New(contr) {
        this._controller := contr
        this._extensions := {}
    }

    ; Attach extension to controller.
    ; `ext` can be either:
    ; - extension object
    ; - extension name (class must be registered with RegisterExtension)
    ; Example:
    /*
    extensionManager.Attach("ext1", { setting1: "abc" })
    extensionManager.Attach(new CustomExtension(), { option: "123" })
    */
    Attach(ext, settings = "") {
        if (IsObject(ext)) {
            extObject := ext
        } else {
            extObject := this._GetExtensionObject(ext)
        }
        extObject.Attach(this._controller, settings)
        this._extensions[extObject.NAME] := extObject
        return this
    }

    _GetExtensionObject(extName) {
        if (!this._EXTENSION_CLASSES.HasKey(extName)) {
            throw, "Unknown extension name:" extName
        }
        extClass := this._EXTENSION_CLASSES[extName]
        return new extClass()
    }

    ; Attach all registered extensions.
    ; allSettings is map from extension name to settings.
    ; Example:
    /*
    extensionManager.AttachAll(contr, { ext1: { setting1: "abc" }, ext2: { setting: "def" } })
    */
    AttachAll(allSettings = "") {
        for extName, extClass in this._EXTENSION_CLASSES {
            extObject := new extClass()
            settings := allSettings[extName]
            extObject.Attach(this._controller, settings)
            this._extensions[extName] := extObject
        }
        return this
    }

    ; Activate all attached extensions.
    ; If extension is not attached, its functions are not used with given controller.
    ; Should be called after `Attach` and `AttachAll` methods. Do not call them after `Activate`.
    ; Examples:
    /*
    extensionManager.AttachAll(contr, { ext1: { setting1: "abc" }, ext2: { setting: "def" } })
    extensionManager.Activate()
    */
    Activate() {
        for name, extObject in this._extensions {
            extObject.Activate(this._extensions)
        }
        return this
    }

    GetExtension(extensionName) {
        return this._extensions[extensionName]
    }
}
