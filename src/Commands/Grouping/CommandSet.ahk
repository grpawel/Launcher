#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk

class CommandSet extends Command {
    commands := {}
    doesNeedGui := true

    _guiControl :=
    _inputChangedSubscription :=
    _returnPressedSubscription :=
    static _DEFAULT_OPTIONS := { "":""
        , "typingMatch": "exact" }

    ; Options:
    ; typingMatch - how to match commands when typing:
    ;       "exact" - whole key must be typed
    ;       "immediate" - run command as soon as only one key matches input
    __New(options = "") {
        this._options := MergeArrays(this._DEFAULT_OPTIONS, options)
    }

    Run(mainController) {
        mainController.GetGui().DisableAll()
        this._guiControl := mainController.GetGui().AddTextInput({ header: this.GetDescription() })
        this._inputChangedSubscription := this._guiControl.SubscribeInputChanged(this._OnUserInput.Bind(this, mainController))
        this._returnPressedSubscription := this._guiControl.SubscribeReturnPressed(this._OnReturnPressed.Bind(this, mainController))
    }

    _OnUserInput(mainController, input) {
        matchingMode := this._options.typingMatch
        if (matchingMode == "exact"
                && this.commands.HasKey(input)) {
            this._RunCommand(this.commands[input], mainController)
            return
        }
        if (matchingMode == "immediate") {
            commandKey := this._FindOnlyCommandKeyStartingWith(input)
            if (commandKey != false) {
                this._RunCommand(this.commands[commandKey], mainController)
            }
            return
        }
    }

    _OnReturnPressed(mainController, input) {
        if (input == "") {
            return
        }
        matchingCommandKey := this._FindOnlyCommandKeyStartingWith(input)
        if (matchingCommandKey != false) {
            this._RunCommand(this.commands[matchingCommandKey], mainController)
        }
    }

    ; Returns command key only if exactly one key starts with given beginning.
    _FindOnlyCommandKeyStartingWith(beginning) {
        matchingCommandKeys := []
        for key, value in this.commands {
            if (StartsWith(key, beginning)) {
                matchingCommandKeys.Push(key)
                if (matchingCommandKeys.Length() > 1) {
                    ; found multiple matching command before - can stop here
                    ; TODO: instead message to user
                    return false
                }
            }
        }
        if (matchingCommandKeys.Length() == 1) {
            return matchingCommandKeys[1]
        } else {
            return false
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
