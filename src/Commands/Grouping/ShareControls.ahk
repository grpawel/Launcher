#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Commands\Technical\MethodDecorator.ahk
#Include %A_ScriptDir%\src\Controller\Controller.ahk
#Include %A_ScriptDir%\src\Gui\Gui.ahk
#Include %A_ScriptDir%\src\Commands\Technical\UseController.ahk

; Share gui controls between commands.
; First command that creates a control decides about its options.
; If a command uses two controls of same type (eg. two inputs) both are created.
; Can be used to combine for example `Search` and `CommandSet` commands.
; Order in which commands receive events is random.
; Gui is destroyed after all given commands try to destroy it (minus noDestroyCommands option).
; Options:
; order: "usePriorities" - (default) commands will receive events in order,
;                          so event from control is first received by `commands[1]`, then `commands[2]` etc.
;                          Max 32 controls are supported.
;                          Do not use if any command is using event priorities (CommandSet and Search aren't using)
; order: "random" - commands will receive events from controls in random order.
;                   No limit to number of controls.
; allowDisabling: boolean (default: true) - allow commands to disable controls. Has no effect on destroying gui.
; noDestroyCommands: int (default: 0) - number of commands that do not attempt to destroy gui. 
; Example:
/*
; Use common input for all searches - will open three websites
new ShareControls([ new ShowMessage("Use multiple search engines")
                   , new Search("google.com/search?q=REPLACEME")
                   , new Search("duckduckgo.com/?q=REPLACEME")
                   , new Search("bing.com/search?q=REPLACEME")])
*/
/*
; Add "hotstrings" to search
searchHotstrings := new CommandSet({ destroyGuiAfter: "never" })
searchHotstrings.AddCommand("ahk", new TypeText("{Backspace}{Backspace}{Backspace}AutoHotkey ", { when: "immediate" }))
searchHotstrings.AddCommand("w10", new TypeText("{Backspace}{Backspace}{Backspace}Windows 10 ", { when: "immediate" }))

new ShareControls([ _.Search("google.com/search?q=REPLACEME").SetDescription("Search Google")
                  , searchHotstrings ]
                 , { allowDisabling: false, noDestroyCommands: 1 }).SetDescription("Search with hotstrings")
*/

class ShareControls extends Command {
    static _DEFAULT_OPTIONS := { "order": "usePriorities"
                               , "allowDisabling": true
                               , "noDestroyCommands": 0 }

    __New(commands, options = "") {
        this._options := MergeArrays(this._DEFAULT_OPTIONS, options)
        static V := new ValidatorFactory()
        static VAL := V.Object({ "order": V.OneOf(["usePriorities", "random"])
                               , "allowDisabling": V.Boolean()
                               , "noDestroyCommands": V.PositiveInt() })
        VAL.ValidateAndShow(this._options)

        this._commands := commands
    }

    Run(contr, context) {
        gui := contr.GetGui()
        sharedOptions := {}
        sharedOptions.guiDestroyAttempts := this._commands.Length() - this._options.noDestroyCommands
        sharedOptions.overrideSubscriptionPriority := this._options.order == "usePriorities"
        sharedOptions.allowDisabling := this._options.allowDisabling

        shared := new ShareControls._Shared(gui, sharedOptions)
        for i, command in this._commands {
            guiDecorator := new this._GuiDecorator(shared, i)
            decoratedGui := new MethodDecorator(gui, guiDecorator, ["AddTextInput", "AddListView", "AddText", "Destroy"])
            controllerDecorator := new this._ControllerDecorator(contr, decoratedGui)
            decoratedController := new MethodDecorator(contr, controllerDecorator, ["GetGui", "RunCommand", "RunCommandWithoutEvents"])
            controllerDecorator.SetDecorated(decoratedController)

            contr.RunCommand(command, context, decoratedController)
        }
    }

    DoesNeedGui() {
        return true
    }

    class _ControllerDecorator {
        __New(original, decoratedGui) {
            this._original := original
            this._decoratedGui := decoratedGui
        }

        SetDecorated(decorated) {
            this._decorated := decorated
        }

        GetGui() {
            return this._decoratedGui
        }

        RunCommand(com, context = "", contr = "") {
            return this._original.RunCommand(com, context, this._decorated)
        }

        RunCommandWithoutEvents(com, context = "", contr = "") {
            return this._original.RunCommand(com, context, this._decorated)
        }
    }

    ; Stores controls shared between commands
    class _Shared {
        _controlsByName := {}

        __New(gui, sharedOptions) {
            this._gui := gui
            this._guiDestroyAttemptsLeft := sharedOptions.guiDestroyAttempts
            this._overrideSubscriptionPriority := sharedOptions.overrideSubscriptionPriority
            this._allowDisabling := sharedOptions.allowDisabling
        }

        ; Returns cached control or creates new one and returns it.
        GetControl(controlName, nthControlOfThisType, eventPriority, controlOptions = "") {
            control := this._GetOrCreateControl(controlName, nthControlOfThisType, controlOptions)
            control := this._DecorateControl(control, eventPriority)
            return control
        }

        _GetOrCreateControl(controlName, nthControlOfThisType, controlOptions) {
            EnsureHasKey(this._controlsByName, controlName, [])
            controlExists := this._controlsByName[controlName].MaxIndex() >= nthControlOfThisType
            if (!controlExists) {
                control := this._gui._AddControl(controlName, controlOptions)
                this._controlsByName[controlName].Push(control)
            } else {
                control := this._controlsByName[controlName][nthControlOfThisType]
            }
            return control
        }

        _DecorateControl(control, eventPriority) {
            decoratorOptions := { allowDisabling: this._allowDisabling }
            if (this._overrideSubscriptionPriority) {
                decoratorOptions["subscribeOptionsOverride"] := { priority: eventPriority }
            }
            return new ShareControls._ControlDecorator(control, decoratorOptions)
        }

        ; Destroy gui after each command calls `gui.Destroy()`
        Destroy() {
            this._guiDestroyAttemptsLeft -= 1
            if (this._guiDestroyAttemptsLeft <= 0) {
                this._gui.Destroy()
            }
        }
    }

    ; Returns controls received from `shared`
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

    ; Override options (second argument) in all methods starting with "Subscribe"
    class _ControlDecorator {
        __New(control, decoratorOptions) {
            this._control := control
            this._subscribeOptionsOverride := decoratorOptions.subscribeOptionsOverride
            this._allowDisabling := decoratorOptions.allowDisabling
        }

        __Call(methodName, args*) {
            control := this._control
            if (StartsWith(methodName, "Subscribe")) {
                subscriber := args[1]
                options := args[2]
                return control[methodName](subscriber, MergeArrays(options, this._subscribeOptionsOverride))
            } else if (methodName == "Disable") {
                if (this._allowDisabling) {
                    return this._control.Disable()
                }
            } else {
                return control[methodName](args*)
            }
        }
    }
}
