class ExtensionManager {
    _extensions := {}

    RegisterExtension(obj) {
        name := obj.name
        this._extensions[name] := obj
    }

    ; Attach extensions to given controller.
    ; If extension is not attached, its functions are not used with given controller.
    ; `extensionNames` (string[] | "all") - extensions to use
    ; `settings` - extension specific settings
    ; Examples:
    ; extManager.Attach(controller, "all", { ext1: { setting1: "abc" }, ext2: { setting: "def" } })
    ; extManager.Attach(controller, ["ext1"], { ext1: { setting1: "abc" } })
    Attach(controller, extensionNames, settings = "") {
        extensions := this._GetExtensionsFromNames(extensionNames)
        for i, extension in extensions {
            extensionSettings := settings[extension.name]
            extension.Attach(controller, extensions, extensionSettings)
        }
    }

    _GetExtensionsFromNames(extensionNames) {
        if (extensionNames == "all") {
            return this._extensions
        }
        extensions := []
        for i, name in extensionNames {
            if (!this._extensions.HasKey(name)) {
                Throw, "Extension ``" name "`` does not exist or is not registered."
            }
            extensions.Push(this._extensions[name])
        }
        return extensions
    }
}

extensionManager := new ExtensionManager()
