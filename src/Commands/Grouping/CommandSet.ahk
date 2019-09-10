#Include %A_ScriptDir%\src\Commands\Command.ahk

class CommandSet extends Command {
    commands := {}
    doesNeedGui := true

    _keyPressedSubscription :=

    ; These commands are run just before and after one selected by user.
    ; Results of these commands are not used.
    commandsBeforeRunning := []
    commandsAfterRunning := []

    Run(mainController) {
        global eventBus
        this._keyPressedSubscription := eventBus.Subscribe("keyPressed", this._OnUserInput.Bind(this, mainController))
        GuiAddInput()
    }

    _OnUserInput(mainController, input) {
        if (not this.commands.HasKey(input)) {
            return
        }
        global eventBus
        eventBus.Unsubscribe(this._keyPressedSubscription)
        closeGuiAfter := true
        for i, commandBefore in this.commandsBeforeRunning {
            %commandBefore%(mainController)
            closeGuiAfter := closeGuiAfter && !commandBefore.doesNeedGui
        }

        command := this.commands[input]
        %command%(mainController)
        closeGuiAfter := closeGuiAfter && !command.doesNeedGui

        for i, commandAfter in this.commandsAfterRunning {
            %commandAfter%(mainController)
            closeGuiAfter := closeGuiAfter && !commandAfter.doesNeedGui
        }
        if (closeGuiAfter) {
            gui_destroy()
        }
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
