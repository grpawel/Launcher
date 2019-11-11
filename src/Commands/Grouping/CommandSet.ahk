#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk

; Store a list of commands with their keys
; Shows input in gui and runs matching command
; 
; Split into three classes for readability.
class CommandSet extends Command {
    _gui :=
    _backend :=
    _eventBus := new EventBus()
    static _DEFAULT_OPTIONS := { "typingMatch": "exact" }

    ; Options:
    ; typingMatch - how to match commands when typing:
    ;       "exact" - (default) whole key must be typed
    ;       "immediate" - run command as soon as only one key starts with input
    ;       ["atLeast", N] - try to match immediately if there are at least N characters
    ;       "onlyReturn" - tries to match only when Return key is pressed
    __New(options = "") {
        this._options := MergeArrays(this._DEFAULT_OPTIONS, options)
        static V := new ValidatorFactory()
        static VAL := V.Object({"typingMatch": V.Or([ V.Equal("exact")
                                                    , V.Equal("immediate")
                                                    , V.Object({1: V.Equal("atLeast"), 2: V.PositiveInt()})
                                                    , V.Equal("onlyReturn") ]) })
        VAL.ValidateAndShow(this._options)
        this.AddTags(["compound"])

        this._backend := new _CommandSetBackend()
        this._gui := new _CommandSetGui(this, this._backend, this._options.typingMatch)
    }

    Run(contr) {
        this._gui.Run(contr)
    }

    AddCommand(key, com) {
        this._backend.commands[key] := com
        return this
    }

    AddCommands(arr) {
        if (IsFunc(arr.GetCommands)) {
            ; arr is CommandSet or similar
            AddAll(this._backend.commands, arr.GetCommands())
        } else {
            ; arr is an array
            AddAll(this._backend.commands, arr)
        }
        return this
    }

    GetCommands() {
        return this._backend.commands
    }

    GetCommand(key) {
        return this._backend.commands[key]
    }

    RemoveCommand(key) {
        this._backend.commands.Delete(key)
        return this
    }

    DoesNeedGui() {
        return true
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
        for name, com in this._backend.commands {
            if (%filter%(com)) {
                filtered[name] := com
            }
        }
        filteredCommandSet := new CommandSet()
        filteredCommandSet._backend.commands := filtered
        return filteredCommandSet
    }

    ; Commands are shared between original and duplicate - changes to them are visible in both.
    ; List of commands itself is not shared - adding commands adds them only to single commandSet.
    Duplicate() {
        duplicate := base.Duplicate()
        duplicate._backend.commands := ObjClone(this._backend.commands)
        return duplicate
    }

    GetGuiControl() {
        return this._gui.inputControl
    }
}

class _CommandSetGui {
    _commandSet := 

    inputControl :=

    _inputChangedSubscription :=
    _returnPressedSubscription :=
    _inputDestroyedSubscription := 
    _inputDisabledSubscription := 

    __New(comSet, backend, matchingMode) {
        this._commandSet := comSet
        this._backend := backend
        this._matchingMode := matchingMode
    }

    Run(contr) {
        gui := contr.GetGui()
        gui.DisableAll()
        if (this._commandSet.GetDescription() != "") {
            gui.AddText({ text: this._commandSet.GetDescription() })
        }
        this.inputControl := gui.AddTextInput()
        this._inputChangedSubscription := this.inputControl.SubscribeInputChanged(this._OnUserInput.Bind(this, contr))
        this._returnPressedSubscription := this.inputControl.SubscribeReturnPressed(this._OnReturnPressed.Bind(this, contr))
        this._inputDestroyedSubscription := this.inputControl.SubscribeDestroyed(this._OnInputNotActive.Bind(this, contr))
        this._inputDisabledSubscription := this.inputControl.SubscribeDisabled(this._OnInputNotActive.Bind(this, contr))
        gui.Show()
    }

    _OnUserInput(contr, input) {
        if (this._matchingMode == "exact") {
            this._MatchExactAndRun(contr, input)
            return
        }
        if (this._matchingMode == "immediate") {
            runnedCommand := this._MatchExactAndRun(contr, input)
            if (!runnedCommand) {
                this._SetInputIfOneMatches(contr, input)
            }
            return
        }
        if (this._matchingMode[1] == "atLeast") {
            runnedCommand := this._MatchExactAndRun(contr, input)
            if (!runnedCommand) {
                isAtLeastN := StrLen(input) >= this._matchingMode[2]
                if (isAtLeastN) {
                    this._SetInputIfOneMatches(contr, input)
                }
            }
            return
        }
    }

    _OnReturnPressed(contr, input) {
        if (input == "") {
            return
        }
        commandKey := this._SetInputIfOneMatches(contr, input)
        if (this._matchingMode == "onlyReturn" && commandKey != "") {
            this._RunCommand(this._backend.commands[commandKey], contr)
        }
    }

    _MatchExactAndRun(contr, input) {
        if (this._backend.commands.HasKey(input)) {
            this._RunCommand(this._backend.commands[input], contr)
            return true
        }
        return false
    }

    ; Set input field to full command key, if only one command key starts with input
    ; Returns full key if matched or empty string
    _SetInputIfOneMatches(contr, input) {
        commandKey := this._backend.FindOnlyCommandKeyStartingWith(input)
        if (commandKey != "") {
            this.inputControl.SetText(commandKey)
            return commandKey
        }
        return ""
    }

    _RunCommand(matchedCommand, contr) {
        contr.RunCommand(matchedCommand, {caller: this._commandSet })
        if (!matchedCommand.DoesNeedGui()) {
            this._inputChangedSubscription.Unsubscribe()
            this._returnPressedSubscription.Unsubscribe()
            contr.GetGui().Destroy()
        }
    }

    _OnInputNotActive(contr) {
        this._commandSet._eventBus.Emit("disabled")
        this._inputDestroyedSubscription.Unsubscribe()
        this._inputDisabledSubscription.Unsubscribe()
    }
}

class _CommandSetBackend {
    commands := {}

    ; Returns command key only if exactly one key starts with given beginning.
    FindOnlyCommandKeyStartingWith(beginning) {
        matchingCommandKeys := []
        for key, value in this.commands {
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
}
