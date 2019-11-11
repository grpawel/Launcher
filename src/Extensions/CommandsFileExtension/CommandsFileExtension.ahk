#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\DeleteCommandDialog.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\EditCommandDialog.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\MoveCommandDialog.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Editor\CreateCommandDialog.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\Commands\Actions\ExportFileCommands.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\CommandsFile.ahk
#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\IncludeCommandsFile.ahk

#Include %A_ScriptDir%\src\Commands\Grouping\CommandSet.ahk

extensionManager.RegisterExtension(new CommandsFileExtension())

class CommandsFileExtension {
    name := "desktops"

    _commandSettings := {}

    ; Singleton is required to have commands registered in one global object.
    static _instance :=
    __New() {
        if (CommandsFileExtension._instance == "") {
            CommandsFileExtension._instance := this
            CommandSet.IncludeCommandsFile := Func("_CommandSet_IncludeCommandsFile")
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
