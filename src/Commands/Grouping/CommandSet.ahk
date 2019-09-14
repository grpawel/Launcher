#Include %A_ScriptDir%\src\Commands\Command.ahk

class CommandSet extends Command {
    commands := {}
    doesNeedGui := true

    _guiControl :=
    _inputChangedSubscription :=
    _returnPressedSubscription :=

    Run(mainController) {
        mainController.GetGui().DisableAll()
        this._guiControl := mainController.GetGui().AddTextInput({ header: this.GetDescription() })
        this._inputChangedSubscription := this._guiControl.SubscribeInputChanged(this._OnUserInput.Bind(this, mainController))
        this._returnPressedSubscription := this._guiControl.SubscribeReturnPressed(this._OnReturnPressed.Bind(this, mainController))
    }

    _OnUserInput(mainController, input) {
        if (not this.commands.HasKey(input)) {
            return
        }
        this._RunCommand(this.commands[input], mainController)
    }

    _OnReturnPressed(mainController, input) {
        if (input == "") {
            return
        }
        matchingCommands := []
        for key, value in this.commands {
            if (StartsWith(key, input)) {
                matchingCommands.Push(key)
                if (matchingCommands.Length() > 1) {
                    ; found multiple matching command before - can stop here
                    ; TODO: instead message to user
                    return
                }
            }
        }
        if (matchingCommands.Length() == 1) {
            this._RunCommand(this.commands[matchingCommands[1]], mainController)
        }
    }

    _RunCommand(matchedCommand, mainController) {
        closeGuiAfter := !matchedCommand.doesNeedGui
        mainController.NotifyCommandAboutToRun(matchedCommand)
        %matchedCommand%(mainController, { caller: this })

        if (closeGuiAfter) {
            this._inputChangedSubscription.Unsubscribe()
            this._returnPressedSubscription.Unsubscribe()
            mainController.GetGui().Destroy()
        }
    }

    ; Returns new empty `CommandSet` with commands matching filter.
    ; `filter` is called for every command and should return `true` or `false`.
    ; If `filter` returns `true`, then command is included.
    ; New `CommandSet` instead of commands only is returned mostly for chaining filters.
    FilterCommands(filter) {
        filtered := {}
        for name, com in this.commands {
            if (%filter%(com)) {
                filtered[name] := com
            }
        }
        filteredCommandSet := new CommandSet()
        filteredCommandSet.commands := filtered
        return filteredCommandSet
    }

    GetGuiControl() {
        return this._guiControl
    }
}
