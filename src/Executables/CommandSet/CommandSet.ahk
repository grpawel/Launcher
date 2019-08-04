#Include %A_ScriptDir%\src\Executables\Executable.ahk

class CommandSet extends Executable {
    subscribedTo := ["keyPressed", "returnPressed"]

    ; These commands are run just before and after one selected by user.
    ; Results of these commands are not used.
    commandsBeforeRunning := []
    commandsAfterRunning := []

    ; Allows to change environment only for this specific CommandSet.
    ; Special commands eg. in commandsBeforeRunning see those changes.
    environmentOverride := {}

    Execute(input, baseEnvironment, executableService) {
        if (not this.commands.HasKey(input)) {
            return false
        }
        environment := baseEnvironment.WithOverrides(this.environmentOverride)
        for i, commandBefore in this.commandsBeforeRunning {
            %commandBefore%(environment)
        }

        command := this.commands[input]
        result := %command%(environment, executableService)

        for i, commandAfter in this.commandsAfterRunning {
            %commandAfter%(environment)
        }
        if (result == "") {
            return true
        }
        return result
    }
}
