#Include %A_ScriptDir%\src\Commands\Command.ahk

class CommandSet extends Command {
    commands := {}
    doesNeedGui := true

    _eventBus := new EventBus()
    _guiControl :=
    _keyPressedSubscription :=

    Run(mainController) {
        mainController.GetGui().DisableAll()
        this._guiControl := mainController.GetGui().AddTextInput({ title: this.title })
        this._keyPressedSubscription := this._guiControl.SubscribeInputChanged(this._OnUserInput.Bind(this, mainController))
    }

    _OnUserInput(mainController, input) {
        if (not this.commands.HasKey(input)) {
            return
        }
        closeGuiAfter := true

        matchedCommand := this.commands[input]
        this._eventBus.Emit("BeforeNextCommandRunned", { "nextCommand": matchedCommand })
        closeGuiAfter := !matchedCommand.doesNeedGui
        %matchedCommand%(mainController, this)

        if (closeGuiAfter) {
            this._keyPressedSubscription.Unsubscribe()
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

    SubscribeBeforeNextCommandRunned(subscriber, duration = "everytime") {
        return this._eventBus.Subscribe("BeforeNextCommandRunned", subscriber, duration)
    }
}
