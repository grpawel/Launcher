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
        this._extensionManager := new ExtensionManager(this)
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

    ; Run given command.
    ; Allows to change controller used for `com` command or any next command that `com` may run.
    RunCommand(com, context = "", contr = "") {
        this._eventBus.Emit("commandAboutToRun", { nextCommand: com })
        this.RunCommandWithoutEvents(com, context, contr)
    }

    ; Run command without firing events.
    ; Is needed because subscribers to `commandAboutToRun` can run commands - it would get stuck in a loop.
    RunCommandWithoutEvents(com, context, contr = "") {
        blockingResult := this._blocker.IsCommandBlocked(com, this)
        if (!blockingResult.doBlock) {
            contr := contr == "" ? this : contr
            com.Run(contr, context)
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
        new ShowMessage(message, { textColor: Colors.RED })
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
    SubscribeCommandAboutToRun(callback, options = "") {
        return this._eventBus.Subscribe("commandAboutToRun", callback, options)
    }

    ; Payload: `{ rootCommand: command }`
    SubscribeRootCommandAboutToRun(callback, options = "") {
        return this._eventBus.Subscribe("rootCommandAboutToRun", callback, options)
    }

    GetBlocker() {
        return this._blocker
    }

    GetExtensionManager() {
        return this._extensionManager
    }

    GetExtension(name) {
        return this._extensionManager.GetExtension(name)
    }
}
