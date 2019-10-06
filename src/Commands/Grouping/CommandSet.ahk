#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk

class CommandSet extends Command {
    _commands := {}
    _guiControl :=
    _inputChangedSubscription :=
    _returnPressedSubscription :=
    static _DEFAULT_OPTIONS := { "":""
        , "typingMatch": "exact" }

    ; Options:
    ; typingMatch - how to match commands when typing:
    ;       "exact" - (default) whole key must be typed
    ;       "immediate" - run command as soon as only one key starts with input
    ;       ["atLeast", N] - try to match immediately if there are at least N characters
    __New(options = "") {
        this._options := MergeArrays(this._DEFAULT_OPTIONS, options)
        this.AddTags(["compound"])
    }

    Run(mainController) {
        gui := mainController.GetGui()
        gui.DisableAll()
        if (this.GetDescription() != "") {
            gui.AddText({ text: this.GetDescription() })
        }

        this._guiControl := gui.AddTextInput()
        this._inputChangedSubscription := this._guiControl.SubscribeInputChanged(this._OnUserInput.Bind(this, mainController))
        this._returnPressedSubscription := this._guiControl.SubscribeReturnPressed(this._OnReturnPressed.Bind(this, mainController))
    }

    AddCommand(key, com) {
        this._commands[key] := com
        return this
    }

    AddCommands(arr) {
        if (IsFunc(arr.GetCommands)) {
            ; arr is CommandSet or similar
            AddAll(this._commands, arr.GetCommands())
        } else {
            ; arr is an array
            AddAll(this._commands, arr)
        }
        return this
    }

    GetCommands() {
        return this._commands
    }

    GetCommand(key) {
        return this._commands[key]
    }

    DoesNeedGui() {
        return true
    }

    _OnUserInput(mainController, input) {
        matchingMode := this._options.typingMatch
        if (matchingMode == "exact"
                && this._commands.HasKey(input)) {
            this._RunCommand(this._commands[input], mainController)
            return
        }
        if (matchingMode == "immediate") {
            commandKey := this._FindOnlyCommandKeyStartingWith(input)
            if (commandKey != false) {
                this._RunCommand(this._commands[commandKey], mainController)
            }
            return
        }
        if (IsArray(matchingMode) && matchingMode[1] == "atLeast") {
            if (this._commands.HasKey(input)) {
                this._RunCommand(this._commands[input], mainController)
                return
            } else if (StrLen(input) >= matchingMode[2]) {
                commandKey := this._FindOnlyCommandKeyStartingWith(input)
                if (commandKey != false) {
                    this._RunCommand(this._commands[commandKey], mainController)
                }
                return
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
            this._RunCommand(this._commands[matchingCommandKey], mainController)
        }
    }

    ; Returns command key only if exactly one key starts with given beginning.
    _FindOnlyCommandKeyStartingWith(beginning) {
        matchingCommandKeys := []
        for key, value in this._commands {
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
        closeGuiAfter := !matchedCommand.DoesNeedGui()
        mainController.RunCommand(matchedCommand, {caller: this })

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
        for name, com in this._commands {
            if (%filter%(com)) {
                filtered[name] := com
            }
        }
        filteredCommandSet := new CommandSet()
        filteredCommandSet._commands := filtered
        return filteredCommandSet
    }

    GetGuiControl() {
        return this._guiControl
    }
}
