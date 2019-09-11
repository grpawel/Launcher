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
        global globalEventBus
        guiControl := mainController.GetGui().AddTextInput({ title: this.title })
        this._keyPressedSubscription := globalEventBus.Subscribe("keyPressed", this._OnUserInput.Bind(this, mainController, guiControl))
    }

    _OnUserInput(mainController, guiControl, input) {
        if (not this.commands.HasKey(input)) {
            return
        }
        closeGuiAfter := true
        for i, commandBefore in this.commandsBeforeRunning {
            %commandBefore%(mainController, this)
            closeGuiAfter := closeGuiAfter && !commandBefore.doesNeedGui
        }

        command := this.commands[input]
        %command%(mainController, this)
        closeGuiAfter := closeGuiAfter && !command.doesNeedGui

        for i, commandAfter in this.commandsAfterRunning {
            %commandAfter%(mainController, this)
            closeGuiAfter := closeGuiAfter && !commandAfter.doesNeedGui
        }
        if (closeGuiAfter) {
            this._keyPressedSubscription.Unsubscribe()
            mainController.GetGui().Hide()
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
