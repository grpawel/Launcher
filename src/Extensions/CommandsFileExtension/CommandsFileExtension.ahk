#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Grouping\GuiNewCommand.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Helpers\WithCommandsFromFile.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\CommandsFile.ahk

extensionManager.RegisterExtension(new CommandsFileExtension())

class CommandsFileExtension {
    name := "desktops"

    _commandSettings := {}

    ; Singleton is required to have commands registered in one global object.
    static _instance :=
    __New() {
        if (CommandsFileExtension._instance == "") {
            CommandsFileExtension._instance := this
            return this
        } else {
            return CommandsFileExtension._instance
        }
    }

    GetInstance() {
        return CommandsFileExtension._instance
    }

    RegisterCommand(commandName, comment, constructorFields) {
        this._commandSettings[commandName] := { comment: comment, fields: constructorFields }
    }

    GetRegisteredCommands() {
        return this._commandSettings
    }
}

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\RegisterCommands.ahk
