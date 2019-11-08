#Include %A_ScriptDir%\src\Commands\Command.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

#Include %A_ScriptDir%\src\Extensions\CommandsFileExtension\CommandValues.ahk

; Show builder in GUI for simple commands.
; Command is then saved to a file.
class GuiNewCommand extends Command {
    __New(comFile) {
        this._commandsFile := comFile
        this._description := "Create command using GUI"
    }

    Run(contr, context) {
        steps := [ this._StepSelectCommand
                 , this._StepConstructorFields
                 , this._StepCommandKey
                 , this._StepSaveToFile ]
        for i in range(steps.MaxIndex(), 0, -1) {
            steps[i] := steps[i].Bind(this, steps[i+1])
        }
        firstStep := steps[1]
        contr.RunCommand(%firstStep%(new CommandValues()))
    }

    DoesNeedGui() {
        return true
    }

    _StepSelectCommand(nextStep, values) {
        return new GuiCommandBuilder_StepSelectCommand(nextStep, values)
    }

    _StepConstructorFields(nextStep, values) {
        return new GuiCommandBuilder_StepConstructorFields(nextStep, values)
    }

    _StepCommandKey(nextStep, values) {
        return new GuiCommandBuilder_StepCommandKey(nextStep, values)
    }

    _StepSaveToFile(nextStep, values) {
        return new GuiCommandBuilder_StepSaveToFile(this._commandsFile, nextStep, values)
    }
}

; Base class for all steps.
class GuiCommandBuilder_Step extends Command {
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

; Select command to create from commands registered in `CommandsFileExtension.RegisterCommand`.
class GuiCommandBuilder_StepSelectCommand extends GuiCommandBuilder_Step {
    Run(contr) {
        gui := contr.GetGui()
        gui.Reset()
        gui.AddText({ text: "Create new command", textColor: Colors.YELLOW, textColorDisabled: Colors.YELLOW })
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

class GuiCommandBuilder_StepConstructorFields extends GuiCommandBuilder_Step {
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

class GuiCommandBuilder_StepCommandKey extends GuiCommandBuilder_Step {
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

class GuiCommandBuilder_StepSaveToFile extends GuiCommandBuilder_Step {
    __New(comFile, nextStep, values) {
        this._commandsFile := comFile
        base.__New(nextStep, values)
    }

    Run(contr) {
        this._commandsFile.NewCommand(this._values)
        this.NextStep(contr)
    }
}
