#Include <AutoHotkey-SerDes/SerDes>

#Include %A_ScriptDir%\src\Events\EventBus.ahk

; Manages file containing serialized commands.
; File is saved in JSON-like format - escape sequences are different (see https://github.com/cocobelgica/AutoHotkey-SerDes/tree/99e4dcdb084ac8a25dd7db194318b0edadb2f299#remarks).
class CommandsFile {
    _eventBus := new EventBus()

    __New(filePath) {
        this._filePath := filePath
    }

    ; Returns map with command keys as keys (as in `CommandSet.AddCommands()` method).
    ; Map values have same structure as `CommandDTO` object, but `base` is not set.
    ReadCommandDTOs() {
        settings := this._ReadFile()
        return settings.commands
    }

    ; Write command to file. `dto` should be `CommandDTO` object.
    ; Command with existing key will be replaced.
    NewCommand(dto) {
        settings := this._ReadFile()
        settings.commands[dto.key] := dto
        SerDes(settings, this._filePath, 2)
        this._eventBus.Emit("commandCreated", dto)
    }

    DeleteCommand(dto) {
        settings := this._ReadFile()
        settings.commands.Delete(dto.key)
        this._eventBus.Emit("commandDeleted", dto)
        SerDes(settings, this._filePath, 2)
    }

    ; Subscribe when `NewCommand` was called.
    SubscribeCommandCreated(subscriber, options := "") {
        this._eventBus.Subscribe("commandCreated", subscriber, options)
    }

    SubscribeCommandDeleted(subscriber, options := "") {
        this._eventBus.Subscribe("commandDeleted", subscriber, options)
    }

    _ReadFile() {
        filePath := this._filePath
        if (!FileExist(filePath)) {
            this._CreateFile(filePath)
        }
        FileRead, fileContents, %filePath%
        settings := SerDes(fileContents)
        return settings
    }

    _CreateFile(filePath) {
        obj := { meta: { "version": "1" }, commands: {} }
        SerDes(obj, filePath, 2)
    }
}
