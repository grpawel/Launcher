examples := [ { id: 1, proc: "Basic", name: "Basic" }
            , { id: 2, proc: "CreatingCommands", name: "Creating commands" }
            , { id: 3, proc: "SelectingCommands", name: "Selecting commands" }  ]

for i, example in examples {
    buttonName := "&"example.id ". " example.name
    buttonHandler := Func("RunExample").Bind(example)
    Gui, listExamples: Add, Button, xm, %buttonName%
    GuiControl, listExamples: +g, %buttonName%, %buttonHandler%

}
Gui, listExamples: Add, Button, xm gExitExamples, &Close
Gui, listExamples: Show
return

RunExample(example) {
    Gui, listExamples: Hide
    exampleName := example.name
    Gui, activeExample: Add, Text,, Active example:`n%exampleName%
    Gui, activeExample: Add, Button, xm gResetExamples, Reset examples
    Gui, activeExample: Show
    exampleProcName := example.proc
    GoSub, %exampleProcName%
}

ResetExamples:
    Reload

ExitExamples:
    ExitApp

#Include %A_ScriptDir%\Examples\Basic.ahk
#Include %A_ScriptDir%\Examples\CreatingCommands.ahk
#Include %A_ScriptDir%\Examples\SelectingCommands.ahk
