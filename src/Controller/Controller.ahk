#Include %A_ScriptDir%\src\Controller\CommandBlocker.ahk
#Include %A_ScriptDir%\src\Events\EventBus.ahk
#Include %A_ScriptDir%\src\Functions\Predicates.ahk

class Controller {
    _rootCommand := {}
    _eventBus := new EventBus()

    __New(environment, gui) {
        this._environment := environment
        this._gui := gui
        this._blocker := new CommandBlocker()
    }

    Execute() {
        if (!this._gui.IsVisible()) {
            this._eventBus.Emit("rootCommandAboutToRun", { rootCommand: this._rootCommand })
            this.RunCommand(this._rootCommand)
        } else {
            this._gui.Destroy()
        }
    }

    SetRootCommand(rootCommand) {
        this._rootCommand := rootCommand
    }

    GetEnvironment() {
        return this._environment
    }

    GetGui() {
        return this._gui
    }

    RunCommand(com, context = "") {
        this._eventBus.Emit("commandAboutToRun", { nextCommand: com })
        this.RunCommandWithoutEvents(com, context)
    }

    ; Run command without firing events.
    ; Stops loops when command subscribes `commandAboutToRun` - it would run again and again infinitely.
    RunCommandWithoutEvents(com, context) {
        blockingResult := this._blocker.IsCommandBlocked(com, this)
        if (!blockingResult.doBlock) {
            com.Run(this, context)
        } else {
            if (blockingResult.message != "") {
                this._ShowBlockingMessageHacky(com, blockingResult.message)   
            }
        }
    }

    _ShowBlockingMessageHacky(com, message) {
        ; If command does not need gui, `CommandSet` will destroy the gui after command is finished.
        ; We show the message when command would be run, so before gui is destroyed.
        ; This has an effect of the message briefly blinking to the user.
        ; To prevent this, we change the command so it says it needs gui - `CommandSet` won't destroy gui.
        ; Then after user closes gui previous behavior is restored.
        if (!com.DoesNeedGui()) {
            originalMethod := com.DoesNeedGui
            originalMethodIsFromBase := !com.HasKey("DoesNeedGui")
            com.DoesNeedGui := AlwaysTrue()
            ; restore original behavior after gui is destroyed
            new WaitForGuiDestroyed(new FunctionToCommand(this._RestoreOriginalDoesNeedGui.Bind(this, com, originalMethod, originalMethodIsFromBase)))
                                .Run(this, {})
        }
        new ShowMessage(message, { textColor: Colors.RED
                                 , disablePrevious: true })
                       .Run(this, {})
    }

    _RestoreOriginalDoesNeedGui(com, originalMethod, orignalMethodIsFromBase) {
        if (orignalMethodIsFromBase) {
            ; `DoesNeedGui` method originally was from base object => delete our override
            com.Delete("doesNeedGui")
        } else {
            ; `DoesNeedGui` method originally was from instance object itself => restore (probably rare)
            com.DoesNeedGui := originalMethod
        }
    }

    ; Payload: `{ nextCommand: command }`
    SubscribeCommandAboutToRun(subscriber, options = "") {
        return this._eventBus.Subscribe("commandAboutToRun", subscriber, options)
    }

    ; Payload: `{ rootCommand: command }`
    SubscribeRootCommandAboutToRun(subscriber, options = "") {
        return this._eventBus.Subscribe("rootCommandAboutToRun", subscriber, options)
    }

    GetBlocker() {
        return this._blocker
    }
}
