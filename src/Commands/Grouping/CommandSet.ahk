#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk

; Store a list of commands with their keys.
; Shows input in gui and runs matching command.
; 
; Split into three classes for readability.
; Options:
; typingMatch - how to match commands when typing:
;   "exact" - (default) whole key must be typed
;   "immediate" - run command as soon as only one key starts with input
;   ["atLeast", N] - try to match immediately if there are at least N characters
;   "onlyReturn" - tries to match only when Return key is pressed
; destroyGuiAfter: 
;   "notNeedingCommand" (default) - destroy gui after running command that does not need gui
;   "always" - always destroy gui after running command
;   "never" - never destroy gui after running command
class CommandSet extends Command {
    _gui :=
    _backend :=
    _eventBus := new EventBus()
    static _DEFAULT_OPTIONS := { typingMatch: "exact"
                               , destroyGuiAfter: "notNeedingCommand" }

    __New(options = "") {
        this._options := MergeArrays(this._DEFAULT_OPTIONS, options)
        static V := new ValidatorFactory()
        static VAL := V.Object({ "typingMatch": V.Or([ V.Equal("exact")
                                                     , V.Equal("immediate")
                                                     , V.Object({ 1: V.Equal("atLeast"), 2: V.PositiveInt() })
                                                     , V.Equal("onlyReturn") ])
                               , "destroyGuiAfter": V.OneOf([ "notNeedingCommand"
                                                            , "always"
                                                            , "never" ]) })
        VAL.ValidateAndShow(this._options)

        this._backend := new _CommandSetBackend()
        this._gui := new _CommandSetGui(this, this._backend, this._options.typingMatch, this._options.destroyGuiAfter)
        this.AddTags(["composite"])
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
    ; Payload is empty.
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

    __New(comSet, backend, matchingMode, destroyGuiMode) {
        this._commandSet := comSet
        this._backend := backend
        this._matchingMode := matchingMode
        this._destroyGuiMode := destroyGuiMode
    }

    Run(contr) {
        gui := contr.GetGui()
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
                this._MatchBeginningAndRun(contr, input)
            }
            return
        }
        if (this._matchingMode[1] == "atLeast") {
            runnedCommand := this._MatchExactAndRun(contr, input)
            if (!runnedCommand) {
                isAtLeastN := StrLen(input) >= this._matchingMode[2]
                if (isAtLeastN) {
                    this._MatchBeginningAndRun(contr, input)
                }
            }
            return
        }
    }

    _OnReturnPressed(contr, input) {
        if (input == "") {
            return
        }
        commandKey := this._MatchBeginningAndRun(contr, input)
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
    _MatchBeginningAndRun(contr, input) {
        commandKey := this._backend.FindOnlyCommandKeyStartingWith(input)
        if (commandKey != "") {
            this.inputControl.SetText(commandKey, { noEvents: true })
            this._RunCommand(this._backend.commands[commandKey], contr)
            return commandKey
        }
        return ""
    }

    _RunCommand(matchedCommand, contr) {
        if (!matchedCommand.UsesExistingControl()) {
            this.inputControl.Disable()
        }
        contr.RunCommand(matchedCommand, {caller: this._commandSet })
        destroyGui := this._destroyGuiMode == "notNeedingCommand" && !matchedCommand.DoesNeedGui()
                    || this._destroyGuiMode == "always"
        noDestroyGui := this._destroyGuiMode == "never"
        if (destroyGui && !noDestroyGui) {
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
