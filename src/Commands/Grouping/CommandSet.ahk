#Include %A_ScriptDir%\src\Commands\Executable.ahk

class CommandSet extends Executable {
    commands := {}

    subscribedTo := ["keyPressed", "returnPressed"]

    ; These commands are run just before and after one selected by user.
    ; Results of these commands are not used.
    commandsBeforeRunning := []
    commandsAfterRunning := []

    Execute(input, mainController) {
        if (not this.commands.HasKey(input)) {
            return false
        }
        for i, commandBefore in this.commandsBeforeRunning {
            %commandBefore%(mainController)
        }

        command := this.commands[input]
        result := %command%(mainController)

        for i, commandAfter in this.commandsAfterRunning {
            %commandAfter%(mainController)
        }
        if (result == "") {
            return true
        }
        return result
    }

    ; Returns new empty `CommandSet` with commands matching filter.
    ; `filter` is called for every command and should return `true` or `false`.
    ; If `filter` returns `true`, then command is included.
    ; New `CommandSet` instead of commands only is returned mostly for chaining filters.
    FilterCommands(filter) {
        filtered := {}
        for name, command in this.commands {
            if (%filter%(command)) {
                filtered[name] := command
            }
        }
        commandSet := new CommandSet()
        commandSet.commands := filtered
        return commandSet
    }
}
