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

        this._backend := new _CommandSetBackend(this)
        this._gui := new _CommandSetGui(this, this._backend, this._options.typingMatch, this._options.destroyGuiAfter)
        this.AddTags(["composite"])
    }

    Run(contr) {
        this._gui.Run(contr)
    }

    Add(key, com) {
        this._backend.AddCommand(key, com)
        return this
    }

    AddMany(arr) {
        if (IsFunc(arr.GetAll)) {
            ; arr is CommandSet or similar
            this._backend.AddCommands(arr.GetAll())
        } else {
            ; arr is an array
            this._backend.AddCommands(arr)
        }
        return this
    }

    Get(key) {
        return this._backend.GetCommand(key)
    }

    GetAll() {
        return this._backend.GetCommands()
    }

    Remove(key) {
        this._backend.RemoveCommand(key)
        return this
    }


    ; Returns new `CommandSet` with commands passed through pipeline.
    ; Description and tags are empty.
    ; Commands from observed CommandSets are included, but no longer observed.
    ; Example:
    /*
    comSet2 := comSet.Transform(new Pipeline().Filter(HasTag(...)))
    ; equivalent to:
    comSet2 := new CommandSet.AddCommands(new Pipeline.Filter(HasTag(...)).Apply(comSet.GetAll()))
    */
    Transform(pipeline) {
        newCommands := pipeline.Apply(this._backend.GetCommands())
        newCommandSet := new CommandSet()
        newCommandSet._backend.AddCommands(newCommands)
        return newCommandSet
    }

    ; Shortcut for transforming with pipeline containing one filter.
    ; Example:
    /*
    comSet2 := comSet.Filter(HasTag(...))
    ; equivalent to:
    comSet2 := comSet.Transform(new Pipeline().Filter(HasTag(...)))
    */
    Filter(predicate) {
        return this.Transform(new Pipeline().Filter(predicate))
    }

    ; Track changes in given commandSet and add commands after filtering and/or mapping.
    Observe(comSet, pipeline = "") {
        this._backend.Observe(comSet, pipeline)
        return this
    }

    DoesNeedGui() {
        return true
    }

    ; Subscribe when `CommandSet` stops being active.
    ; This happens when corresponding input is disabled or destroyed.
    ; Payload is empty.
    SubscribeNotActive(callback, options = "") {
        this._eventBus.Subscribe("disabled", callback, options)
    }

    ; Subscribe when command was added by user or from observed commandSet.
    ; Payload: `{ added: commands }`, `commands` - map from key to command
    SubscribeCommandsAdded(callback, options := "") {
        this._eventBus.Subscribe("commandsAdded", callback, options)
    }

    ; Subscribe when command was removed by user or from observed commandSet.
    ; Payload: `{ removed: commands }`, `commands` - map from key to command
    SubscribeCommandsRemoved(callback, options := "") {
        this._eventBus.Subscribe("commandsRemoved", callback, options)
    }

    ; Commands are shared between original and duplicate - changes to them are visible in both.
    ; List of commands itself is not shared - adding commands adds them only to single commandSet.
    Duplicate() {
        duplicate := base.Duplicate()
        duplicate._backend._commands := ObjClone(this._backend._commands)
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
            this._RunCommand(this._backend.GetCommand(commandKey), contr)
        }
    }

    _MatchExactAndRun(contr, input) {
        com := this._backend.GetCommand(input)
        if (com != "") {
            this._RunCommand(com, contr)
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
            this._RunCommand(this._backend.GetCommand(commandKey), contr)
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
    _commands := {}
    _observed := {}

    __New(comSet) {
        this._commandSet := comSet
    }

    AddCommand(key, com) {
        this._commands[key] := com
        eventPayload := {}
        eventPayload[key] := com
        this._commandSet._eventBus.Emit("commandsAdded", { added: eventPayload })
    }

    AddCommands(comsByKey) {
        AddAll(this._commands, comsByKey)
        this._commandSet._eventBus.Emit("commandsAdded", { added: comsByKey })
    }

    GetCommand(key) {
        com := this._commands[key]
        if (com != "") {
            return com
        }
        for id, observed in this._observed {
            if (observed.commands.HasKey(key)) {
                return observed.commands[key]
            }
        }
        return ""
    }

    GetCommands() {
        commands := this._commands.Clone()
        for id, observed in this._observed {
            AddAll(commands, observed.commands)
        }
        return commands
    }

    ; Returns command key only if exactly one key starts with given beginning.
    FindOnlyCommandKeyStartingWith(beginning) {
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

    RemoveCommand(key) {
        removed := this._commands.Delete(key)
        eventPayload := {}
        eventPayload[key] := removed
        this._commandSet._eventBus.Emit("commandsRemoved", { removed: eventPayload })
    }

    RemoveCommands(keys) {
        removed := {}
        for i, key in keys {
            removed[key] := this._commands.Delete(key)
        }
        this._commandSet._eventBus.Emit("commandsRemoved", { removed: removed })
    }

    Observe(comSet, pipe) {
        id := RandomString(4)
        observed := {}
        observed.commands := {}
        if (pipe == "") {
            pipe := new Pipeline()
        }
        observed.pipeline := pipe
        observed.addedSub := comSet.SubscribeCommandsAdded(this._OnCommandsAdded.Bind(this, id))
        observed.removedSub := comSet.SubscribeCommandsRemoved(this._OnCommandsRemoved.Bind(this, id))
        this._observed[id] := observed
        this._OnCommandsAdded(id, { added: comSet.GetAll() })
    }

    _OnCommandsAdded(id, payload) {
        observed := this._observed[id]
        commands := observed.pipeline.Apply(payload.added)
        AddAll(observed.commands, commands)
        this._commandSet._eventBus.Emit("commandsAdded", { added: commands })
    }

    _OnCommandsRemoved(id, payload) {
        observed := this._observed[id]
        commands := observed.pipeline.Apply(payload.removed)
        for key, com in commands {
            observed.commands.Delete(key)
        }
        this._commandSet._eventBus.Emit("commandsRemoved", { removed: commands })
    }
}
