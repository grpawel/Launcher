#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Commands\Technical\MethodDecorator.ahk
#Include %A_ScriptDir%\src\Controller\Controller.ahk
#Include %A_ScriptDir%\src\Gui\Gui.ahk
#Include %A_ScriptDir%\src\Commands\Technical\UseController.ahk

; Share gui controls between commands.
; Control options are used from command that first created first, second and so on control of some type.
; Can be used to combine for example `Search` and `CommandSet` commands.
; Order in which commands receive events is random.
; Options:
; order: "usePriorities" - (default) commands will receive events in order,
;                          in other words `commands[1]` first receives event from control, then `commands[2]` etc.
;                          Max 32 controls are supported.
;                          Do not use if any command is using event priorities.
; order: "random" - commands will receive events from controls in random order.
;                   No limit to number of controls.
; Examples:


; Example behavior:
; First command in `commands` calls `AddTextInput(someOptions)`
; - new text input is returned, created with `someOptions`
; Second command calls `AddTextInput(otherOptions)`
; - existing text input is returned, `otherOptions` are not used
; Second command calls `AddTextInput(yetAnotherOptions)` again
; - new text input is returned, created with `yetAnotherOptions`

class SharedControls extends Command {
    static _DEFAULT_OPTIONS := { "order": "usePriorities" }

    __New(commands, options = "") {
        this._options := MergeArrays(this._DEFAULT_OPTIONS, options)
        static V := new ValidatorFactory()
        static VAL := V.Object({ "order": V.OneOf(["usePriorities", "random"]) })
        VAL.ValidateAndShow(this._options)

        this._commands := commands
    }

    Run(contr, context) {
        overrideSubscriptionPriority := this._options.order == "usePriorities"
        Debug("len", this._commands.Length())
        shared := new SharedControls._Shared(contr.GetGui(), this._commands.Length(), overrideSubscriptionPriority)
        for i, command in this._commands {
            guiDecorator := new this._GuiDecorator(shared, i)
            decoratedGui := new MethodDecorator(contr.GetGui(), guiDecorator, ["AddTextInput", "AddListView", "AddText", "Destroy"])
            decoratedController := new MethodDecorator(contr, new this._ControllerDecorator(decoratedGui), ["GetGui"])
            ; `decoratedController.RunCommand` still calls `command.Run` with original controller
            ; we want to pass `decoratedController` to the command, but still allow blocking the command
            withControllerCommand := new MethodDecorator(command, new UseController(decoratedController, command), ["Run"])
            contr.RunCommand(withControllerCommand, context)
        }
    }

    DoesNeedGui() {
        return true
    }

    class _ControllerDecorator {
        test := "abd"
        __New(decoratedGui) {
            this._decoratedGui := decoratedGui
            ;this._gui := new SharedControls._SharingInputsGui(inputs)
            ;this._decoratedGui := new MethodDecorator(contr.GetGui(), this._gui, ["AddTextInput", "AddListView", "AddText"])
        }

        GetGui() {
            ; Debug("Get Gui controller")
            return this._decoratedGui
        }
    }

    class _Shared {
        _controlsByName := {}

        __New(gui, commandsCount, overrideSubscriptionPriority) {
            ; Debug("new gui")
            this._gui := gui
            this._activeCommands := commandsCount
            this._overrideSubscriptionPriority := overrideSubscriptionPriority
        }

        ; Returns cached control or creates new one and returns it.
        GetControl(controlName, count, commandNum, controlOptions = "") {
            ;Debug(controlName, count, controlOptions, this._overrideSubscriptionPriority)
            EnsureHasKey(this._controlsByName, controlName, [])
            control := this._GetOrCreateControl(controlName, count, controlOptions)
            if (this._overrideSubscriptionPriority) {
                subscribeOptionsOverride := { priority: commandNum }
                control := new SharedControls._ControlDecorator(control, subscribeOptionsOverride)
            }
            return control
        }

        _GetOrCreateControl(controlName, count, controlOptions = "") {
            controlExists := this._controlsByName[controlName].MaxIndex() >= count
            if (!controlExists) {
                ; Debug("add new")
                control := this._gui._AddControl(controlName, controlOptions)
                this._controlsByName[controlName].Push(control)
            } else {
                control := this._controlsByName[controlName][count]
                Debug("return existing control, empty?", control != "", "count?", count, "keys", Keys(this._controlsByName[controlName]))
            }
            return control
        }

        ; Destroy gui after each command calls `gui.Destroy()`
        Destroy() {
            this._activeCommands -= 1
            Debug("destroy?", this._activeCommands, this._activeCommands <= 0)
            if (this._activeCommands <= 0) {
                this._gui.Destroy()
            }
        }
    }

    class _GuiDecorator {
        ; Stores how many controls of each type were created.
        _controlCounts := {}

        __New(shared, num) {
            this._shared := shared
            this._num := num
        }

        AddTextInput(options = "") {
            return this._GetControl("TextInput", options)
        }

        AddListView(options = "") {
            return this._GetControl("ListViewControl", options)
        }

        AddText(options = "") {
            return this._GetControl("TextView", options)
        }

        _GetControl(controlName, options = "") {
            EnsureHasKey(this._controlCounts, controlName, 0)
            this._controlCounts[controlName] += 1
            return this._shared.GetControl(controlName, this._controlCounts[controlName], this._num, options)
        }

        Destroy() {
            return this._shared.Destroy()
        }
    }

    class _ControlDecorator {
        __New(control, subscribeOptionsOverride) {
            this._control := control
            this._subscribeOptionsOverride := subscribeOptionsOverride
        }

        __Call(methodName, args*) {
            control := this._control
            if (StartsWith(methodName, "Subscribe")) {
                subscriber := args[1]
                options := args[2]
                options := MergeArrays(options, this._subscribeOptionsOverride)
                Debug("call", methodName, options)
                return control[methodName](subscriber, options)
            } else {
                return control[methodName](args*)
            }
        }
        /*

        SubscribeInputChanged(subscriber, options = "") {
            return this._control.SubscribeInputChanged(subscriber, MergeArrays(options, this._newOptions))
        }

        SubscribeReturnPressed(subscriber, options = "") {
            return this._control.SubscribeReturnPressed(subscriber, MergeArrays(options, this._newOptions))
        }

        SubscribeDestroyed(subscriber, options = "") {
            return this._control.SubscribeDestroyed(subscriber, MergeArrays(options, this._newOptions))
        }

        SubscribeDisabled(subscriber, options = "") {
            return this._control.SubscribeDisabled(subscriber, MergeArrays(options, this._newOptions))
        }
        
        SubscribeRowSelected(subscriber, options = "") {
            return this._control.SubscribeRowSelected(subscriber, MergeArrays(options, this._newOptions))
        }
        */
    }
}
