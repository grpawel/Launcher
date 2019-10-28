#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk

class CommandSet extends Command {
    _commands := {}
    _guiControl :=
    _eventBus := new EventBus()
    _inputChangedSubscription :=
    _returnPressedSubscription :=
    _inputDestroyedSubscription := 
    _inputDisabledSubscription := 
    static _DEFAULT_OPTIONS := { "typingMatch": "exact" }

    ; Options:
    ; typingMatch - how to match commands when typing:
    ;       "exact" - (default) whole key must be typed
    ;       "immediate" - run command as soon as only one key starts with input
    ;       ["atLeast", N] - try to match immediately if there are at least N characters
    __New(options = "") {
        this._options := MergeArrays(this._DEFAULT_OPTIONS, options)
        static V := new ValidatorFactory()
        static VAL := V.Object({"typingMatch": V.Or([ V.Equal("exact")
                                                    , V.Equal("immediate")
                                                    , V.Object({1: V.Equal("atLeast"), 2: V.PositiveInt()}) ]) })
        VAL.ValidateAndShow(this._options)
        this.AddTags(["compound"])
    }

    Run(controller) {
        gui := controller.GetGui()
        gui.DisableAll()
        if (this.GetDescription() != "") {
            gui.AddText({ text: this.GetDescription() })
        }
        this._guiControl := gui.AddTextInput()
        this._inputChangedSubscription := this._guiControl.SubscribeInputChanged(this._OnUserInput.Bind(this, controller))
        this._returnPressedSubscription := this._guiControl.SubscribeReturnPressed(this._OnReturnPressed.Bind(this, controller))
        this._inputDestroyedSubscription := this._guiControl.SubscribeDestroyed(this._OnInputNotActive.Bind(this, controller))
        this._inputDisabledSubscription := this._guiControl.SubscribeDisabled(this._OnInputNotActive.Bind(this, controller))
        gui.Show()
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

    _OnUserInput(controller, input) {
        matchingMode := this._options.typingMatch
        if (matchingMode == "exact") {
            this._MatchExact(controller, input)
            return
        }
        if (matchingMode == "immediate") {
            this._MatchImmediate(controller, input)
            return
        }
        if (IsArray(matchingMode) && matchingMode[1] == "atLeast") {
            this._MatchAtLeastN(controller, input, matchingMode)
            return
        }
    }

    _OnReturnPressed(controller, input) {
        if (input == "") {
            return
        }
        return this._MatchImmediate(controller, input)
    }

    _MatchExact(controller, input) {
        if (this._commands.HasKey(input)) {
            this._RunCommand(this._commands[input], controller)
            return true
        }
        return false
    }

    _MatchImmediate(controller, input) {
        commandKey := this._FindOnlyCommandKeyStartingWith(input)
        if (commandKey != "") {
            this._guiControl.SetText(commandKey)
            this._RunCommand(this._commands[commandKey], controller)
            return true
        }
        return false
    }

    _MatchAtLeastN(controller, input, matchingMode) {
        if (!this._MatchExact(controller, input)) {
            isAtLeastN := StrLen(input) >= matchingMode[2]
            if (isAtLeastN) {
                this._MatchImmediate(controller, input)
            }
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
                    return ""
                }
            }
        }
        if (matchingCommandKeys.Length() == 1) {
            return matchingCommandKeys[1]
        } else {
            return ""
        }
    }

    _RunCommand(matchedCommand, controller) {
        destroyGuiAfter := !matchedCommand.DoesNeedGui()
        controller.RunCommand(matchedCommand, {caller: this })

        if (destroyGuiAfter) {
            this._inputChangedSubscription.Unsubscribe()
            this._returnPressedSubscription.Unsubscribe()
            controller.GetGui().Destroy()
        }
    }

    _OnInputNotActive(controller) {
        this._eventBus.Emit("disabled")
        this._inputDestroyedSubscription.Unsubscribe()
        this._inputDisabledSubscription.Unsubscribe()
    }

    ; Subscribe when `CommandSet` stops being active.
    ; This happens when corresponding input is disabled or destroyed.
    SubscribeNotActive(subscriber, options = "") {
        this._eventBus.Subscribe("disabled", subscriber, options)
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

    ; Commands are shared between original and duplicate - changes to them are visible in both.
    ; List of commands itself is not shared - adding commands adds them only to single commandSet.
    Duplicate() {
        duplicate := base.Duplicate()
        duplicate._commands := ObjClone(this._commands)
        return duplicate
    }

    GetGuiControl() {
        return this._guiControl
    }
}
