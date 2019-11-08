#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\CommandValues.ahk

class GuiCommandBuilder extends Command {
    _steps := []

    Create() {
        ; Bind second step to first one, third to second etc.
        ; We have to do it from last one, because binding returns new object
        ; that we bind with previous last one etc.
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

    ; Show commands registered in `CommandsFileExtension.RegisterCommand`
    ; and let user select one.
    SelectCommandClass() {
        this._steps.Push(Func("_GuiCommandBuilder_SelectCommandClass"))
        return this
    }

    ; Fill constructor fields.
    ConstructorFields() {
        this._steps.Push(Func("_GuiCommandBuilder_ConstructorFields"))
        return this
    }

    ; Fill command key, description and tags.
    KeyDescriptionTags() {
        this._steps.Push(Func("_GuiCommandBuilder_KeyDescriptionTags"))
        return this
    }

    ; Save command to file
    SaveToFile(comFile) {
        this._steps.Push(Func("_GuiCommandBuilder_SaveToFile").Bind(comFile))
        return this
    }
}

_GuiCommandBuilder_SelectCommandClass(nextStep, values) {
    return new _GuiCommandBuilder_SelectCommandClass(nextStep, values)
}

_GuiCommandBuilder_ConstructorFields(nextStep, values) {
    return new _GuiCommandBuilder_ConstructorFields(nextStep, values)
}

_GuiCommandBuilder_KeyDescriptionTags(nextStep, values) {
    return new _GuiCommandBuilder_KeyDescriptionTags(nextStep, values)
}

_GuiCommandBuilder_SaveToFile(comFile, nextStep, values) {
    return new _GuiCommandBuilder_SaveToFile(comFile, nextStep, values)
}

; Base class for all steps.
class _GuiCommandBuilder_Step extends Command {
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

    DoesNeedGui() {
        return true
    }
}

class _GuiCommandBuilder_SelectCommandClass extends _GuiCommandBuilder_Step {
    Run(contr) {
        gui := contr.GetGui()
        gui.Reset()
        gui.AddText({ text: "Select command:", textColor: Colors.LIGHT_GRAY, textColorDisabled: Colors.LIGHT_GRAY })
        commandList := new CommandSet({ typingMatch: "immediate" })
        availableCommands := CommandsFileExtension.GetInstance().GetRegisteredCommands()
        for commandName, settings in availableCommands {
            values := this._values.Clone()
            values.name := commandName
            nextStep := this._nextStep
            commandList.AddCommand(commandName, %nextStep%(values).SetDescription(settings.comment))
        }
        contr.RunCommand(WithHelpOpened(commandList))
    }
}

class _GuiCommandBuilder_ConstructorFields extends _GuiCommandBuilder_Step {
    Run(contr) {
        availableCommands := CommandsFileExtension.GetInstance().GetRegisteredCommands()
        fields := availableCommands[this._values.name].fields
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

class _GuiCommandBuilder_KeyDescriptionTags extends _GuiCommandBuilder_Step {
    Run(contr) {
        gui := contr.GetGui()
        gui.Reset()
        gui.AddText({ text: "Command: " this._values.name "(" Join(this._values.fields, ", ") ")", textColor: Colors.YELLOW })
        gui.AddText({ text: "Command key:" })
        this._keyInput := gui.AddTextInput()
        gui.AddText({ text: "Description:" })
        this._descriptionInput := gui.AddTextInput()
        gui.AddText({ text: "Tags (separated by commas, spaces are ignored):" })
        this._tagsInput := gui.AddTextInput()

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
        gui.Reset()
        this.NextStep(contr)
    }

    _FillValues() {
        this._values.key := this._keyInput.GetText()
        this._values.description := this._descriptionInput.GetText()
        tagsStr := this._tagsInput.GetText()
        this._values.tags := StrSplit(tagsStr, ",", " ")
    }
}

class _GuiCommandBuilder_SaveToFile extends _GuiCommandBuilder_Step {
    __New(comFile, nextStep, values) {
        this._commandsFile := comFile
        base.__New(nextStep, values)
    }

    Run(contr) {
        this._commandsFile.NewCommand(this._values)
        this.NextStep(contr)
    }
}
