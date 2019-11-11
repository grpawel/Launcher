#Include %A_ScriptDir%\src\Extensions\ExtensionManager.ahk
#Include %A_ScriptDir%\src\Commands\Grouping\CommandSet.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\DeleteCommandDialog.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\EditCommandDialog.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\MoveCommandDialog.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\CreateCommandDialog.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\ScriptInteraction\ExportFileCommands.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\CommandsFile.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\IncludeCommandsFile.ahk


ExtensionManager.RegisterExtension(CommandsFileExtension)

CommandSet.IncludeCommandsFile := Func("_CommandSet_IncludeCommandsFile")

class CommandsFileExtension {
    static NAME := "commandsFile"

    static _COMMANDS_SETTINGS := {}

    __New() {
        this._commandsSettings := CommandsFileExtension._COMMANDS_SETTINGS.Clone()
    }

    Attach(contr, settings = "") {
    }

    ; Register command for specific controller.
    RegisterCommand(commandName, comment, constructorFields) {
        this._commandsSettings[commandName] := { comment: comment, fields: constructorFields }
    }

    ; (static)
    ; Register command for all controllers.
    ; Extensions for controller should be activated after calling this command
    RegisterCommandGlobal(commandName, comment, constructorFields) {
        this._COMMANDS_SETTINGS[commandName] := { comment: comment, fields: constructorFields }
    }

    GetRegisteredCommands() {
        return this._commandsSettings
    }
}

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\RegisterCommands.ahk
