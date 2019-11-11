#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\CommandValues.ahk

; Builder for creating gui dialogs for creating, deleting etc. commands from command file.
class CommandDialogBuilder extends Command {
    _steps := []

    ; Returns command that goes through all used steps.
    Build() {
        ; Dummy last step, exists only to make Return key work in last command.
        this._steps.Push(Func("_CommandDialogBuilder_Step_ResetGui"))
        ; Bind second step to first one, third to second etc.
        ; We have to do it from last one, because binding returns new object
        ; that we bind with previous last one and so on.
        for i in range(this._steps.MaxIndex(), 0, -1) {
            step := this._steps[i]
            step := ObjBindMethod(step, "Call", this._steps[i+1])
            this._steps[i] := step
        }
        return this
    }

    Run(contr) {
        firstStep := this._steps[1]
        contr.RunCommand(%firstStep%(new CommandValues()))
    }

    ; Show commands saved in a file and select one for further editing.
    SelectExisting(comFile) {
        step := _CommandDialogBuilder_CreateStep("_CommandDialogBuilder_SelectExisting", comFile)
        this._steps.Push(step)
        return this
    }

    ; Show commands registered in `CommandsFileExtension.RegisterCommand`
    ; and let user select one.
    SelectCommandClass() {
        step := _CommandDialogBuilder_CreateStep("_CommandDialogBuilder_SelectCommandClass")
        this._steps.Push(step)
        return this
    }

    ; Fill constructor fields.
    ConstructorFields() {
        step := _CommandDialogBuilder_CreateStep("_CommandDialogBuilder_ConstructorFields")
        this._steps.Push(step)
        return this
    }

    ; Fill command key, description and tags.
    KeyDescriptionTags() {
        step := _CommandDialogBuilder_CreateStep("_CommandDialogBuilder_KeyDescriptionTags")
        this._steps.Push(step)
        return this
    }

    ; Save command to file
    SaveToFile(comFile) {
        step := _CommandDialogBuilder_CreateStep("_CommandDialogBuilder_SaveToFile", comFile)
        this._steps.Push(step)
        return this
    }

    ; Delete command from file
    DeleteFromFile(comFile) {
        step := _CommandDialogBuilder_CreateStep("_CommandDialogBuilder_DeleteFromFile", comFile)
        this._steps.Push(step)
        return this
    }

    ShowSummary(title) {
        step := _CommandDialogBuilder_CreateStep("_CommandDialogBuilder_ShowSummary", title)
        this._steps.Push(step)
        return this
    }
}

; Return function object bound to params. 
; Two parameters are supposed to be left to bind - `nextStep` and `values`.
; After calling will return new command with `className`.
_CommandDialogBuilder_CreateStep(className, params*) {
    static f := Func("_CommandDialogBuilder_Step_New")
    step := ObjBindMethod(f, "Call", className)
    for i, param in params {
        step := ObjBindMethod(step, "Call", param)
    }
    return step
}

; This function is needed, because binding directly to `__New()` does not properly initialize `this` object.
_CommandDialogBuilder_Step_New(className, params*) {
    return new %className%(params*)
}

_CommandDialogBuilder_Step_ResetGui(nextStep, values) {
    return new ResetGui()
}

; Base class for all steps.
class _CommandDialogBuilder_Step extends Command {
    ; nextStep - function that takes `values` and returns command.
    ; values - `CommandValues` object.
    __New(nextStep, values) {
        this._nextStep := nextStep
        this._values := values
    }

    NextStep(contr) {
        nextStep := this._nextStep
        contr.RunCommand(%nextStep%(this._values))
    }

    GetAvailableCommands() {
         return CommandsFileExtension.GetInstance().GetRegisteredCommands()
    }

    DoesNeedGui() {
        return true
    }
}


class _CommandDialogBuilder_SelectExisting extends _CommandDialogBuilder_Step {
    __New(comFile, nextStep, values) {
        this._commandsFile := comFile
        base.__New(nextStep, values)
    }

    Run(contr) {
        gui := contr.GetGui()
        gui.Reset()
        gui.AddText({ text: "Select existing command:", textColor: Colors.LIGHT_GRAY, textColorDisabled: Colors.LIGHT_GRAY })
        commands := new CommandSet()
        valuesList := this._commandsFile.ReadCommandsValues()
        for key, values in valuesList {
            values.base := CommandValues
            nextStep := this._nextStep
            commands.AddCommand(values.key, %nextStep%(values).SetDescription(values.description))
        }
        contr.RunCommand(WithHelpOpened(commands))
    }
}

class _CommandDialogBuilder_SelectCommandClass extends _CommandDialogBuilder_Step {
    Run(contr) {
        gui := contr.GetGui()
        gui.Reset()
        gui.AddText({ text: "Select command:", textColor: Colors.LIGHT_GRAY, textColorDisabled: Colors.LIGHT_GRAY })
        commandList := new CommandSet({ typingMatch: "onlyReturn" })
        availableCommands := this.GetAvailableCommands()
        for commandName, settings in availableCommands {
            values := this._values.Clone()
            values.name := commandName
            nextStep := this._nextStep
            commandList.AddCommand(commandName, %nextStep%(values).SetDescription(settings.comment))
        }
        contr.RunCommand(WithHelpOpened(commandList))
        if (this._values.name != "") {
            commandList.GetGuiControl().SetText(this._values.name)
        }
    }
}

class _CommandDialogBuilder_ConstructorFields extends _CommandDialogBuilder_Step {
    Run(contr) {
        availableCommands := CommandsFileExtension.GetInstance().GetRegisteredCommands()
        fields := availableCommands[this._values.name].fields
        if (Keys(fields).Length() == 0) {
            this.NextStep(contr)
            return
        }
        gui := contr.GetGui()
        gui.Reset()
        gui.AddText({ text: "Command: " this._values.name, textColor: Colors.YELLOW })

        submitHandler := this._UserSubmitted.Bind(this, contr)
        this._inputs := []
        this._keyInput.SubscribeReturnPressed(submitHandler)
        for i, fieldComment in fields {
            gui.AddText({ text: fieldComment ":" })
            input := gui.AddTextInput()
            input.SubscribeReturnPressed(submitHandler)
            this._inputs.Push(input)
            if (this._values.fields[i] != "") {
                input.SetText(this._values.fields[i])
            }
        }
        gui.Show()
    }

    _UserSubmitted(contr) {
        for i, input in this._inputs {
            fieldValue := input.GetText()
            this._values.fields[i] := fieldValue
        }
        this.NextStep(contr)
    }
}

class _CommandDialogBuilder_KeyDescriptionTags extends _CommandDialogBuilder_Step {
    Run(contr) {
        gui := contr.GetGui()
        gui.Reset()
        gui.AddText({ text: "Command: " this._values.name "(" Join(this._values.fields, ", ") ")", textColor: Colors.YELLOW })
        gui.AddText({ text: "Command key:" })
        this._keyInput := gui.AddTextInput()
        if (this._values.key != "") {
            this._keyInput.SetText(this._values.key)
        }
        gui.AddText({ text: "Description:" })
        this._descriptionInput := gui.AddTextInput()
        if (this._values.description != "") {
            this._descriptionInput.SetText(this._values.description)
        }
        gui.AddText({ text: "Tags (separated by commas, spaces are ignored):" })
        this._tagsInput := gui.AddTextInput()
        if (HasAnyKey(this._values.tags)) {
            this._tagsInput.SetText(Join(this._values.tags, ", "))
        }

        submitHandler := this._UserSubmitted.Bind(this, contr)
        this._keyInput.SubscribeReturnPressed(submitHandler)
        this._descriptionInput.SubscribeReturnPressed(submitHandler)
        this._tagsInput.SubscribeReturnPressed(submitHandler)
        gui.Show()
        ; Focus the first input
        Send, {Tab}
    }

    _UserSubmitted(contr) {
        key := this._keyInput.GetText()
        if (key == "") {
            if (!this._emptyKeyMessageShown) {
                contr.GetGui().AddText({ text: "Command key cannot be empty.", textColor: Colors.RED })
                contr.GetGui().Show()
                this._emptyKeyMessageShown := true
            }
            return
        }
        this._FillValues()
        this.NextStep(contr)
    }

    _FillValues() {
        this._values.key := this._keyInput.GetText()
        this._values.description := this._descriptionInput.GetText()
        tagsStr := this._tagsInput.GetText()
        this._values.tags := StrSplit(tagsStr, ",", " ")
    }
}

class _CommandDialogBuilder_SaveToFile extends _CommandDialogBuilder_Step {
    __New(comFile, nextStep, values) {
        this._commandsFile := comFile
        base.__New(nextStep, values)
    }

    Run(contr) {
        this._commandsFile.NewCommand(this._values)
        this.NextStep(contr)
    }
}

class _CommandDialogBuilder_DeleteFromFile extends _CommandDialogBuilder_Step {
    __New(comFile, nextStep, values) {
        this._commandsFile := comFile
        base.__New(nextStep, values)
    }

    Run(contr) {
        this._commandsFile.DeleteCommand(this._values)
        this.NextStep(contr)
    }
}

class _CommandDialogBuilder_ShowSummary extends _CommandDialogBuilder_Step {
    static _WIDTH := 400

    __New(title, nextStep, values) {
        this._title := title
        base.__New(nextStep, values)
    }

    Run(contr) {
        gui := contr.GetGui()
        gui.Reset()
        gui.AddText({ text: this._title, textColor: Colors.YELLOW, width: this._WIDTH })
        rows := []
        rows.Push(["Command:", this._values.name])
        rows.Push(["Key:", this._values.key])
        fields := this.GetAvailableCommands()[this._values.name].fields
        for i, fieldName in fields {
            rows.Push([fieldName, this._values.fields[i]])
        }
        rows.Push(["Description:", this._values.description])
        rows.Push(["Tags:", Join(this._values.tags, ", ")])
        table := gui.AddListView({ width: this._WIDTH })
        table.Populate(rows)
        gui.Show()
        this._returnPressedSubscription := gui.SubscribeReturnPressed(this._OnReturnPressed.Bind(this, contr))
    }

    _OnReturnPressed(contr, focused) {
        this._returnPressedSubscription.Unsubscribe()
        this.NextStep(contr)
    }
}
