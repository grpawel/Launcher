#Include %A_ScriptDir%\src\Commands\Executable.ahk

class CommandSet extends Executable {
    commands := {}
    doesNeedGui := true

    _keyPressedSubscription :=

    ; These commands are run just before and after one selected by user.
    ; Results of these commands are not used.
    commandsBeforeRunning := []
    commandsAfterRunning := []

    Run(mainController) {
        mainController.SetActiveCommand(this)
    }

    Activate(mainController) {
        global eventBus
        this._keyPressedSubscription := eventBus.Subscribe("keyPressed", this._OnUserInput.Bind(this, mainController))
        GuiAddInput()
    }

    Deactivate(mainController) {
        global eventBus
        eventBus.Unsubscribe(this._keyPressedSubscription)
    }

    _OnUserInput(mainController, input) {
        if (not this.commands.HasKey(input)) {
            return
        }
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
