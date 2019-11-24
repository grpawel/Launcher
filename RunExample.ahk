examples := [ { id: 1, proc: "BasicExample", name: "Basic" }
            , { id: 2, proc: "CreatingCommandsExample", name: "Creating commands" }
            , { id: 3, proc: "UsingGuiExample", name: "Using GUI" }
            , { id: 4, proc: "EnvironmentExample", name: "Environment" }
            , { id: 5, proc: "ComposingExample", name: "Composing" } ]

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

#Include %A_ScriptDir%\Examples\1_Basic.ahk
#Include %A_ScriptDir%\Examples\2_CreatingCommands.ahk
#Include %A_ScriptDir%\Examples\3_UsingGui.ahk
#Include %A_ScriptDir%\Examples\4_Environment.ahk
#Include %A_ScriptDir%\Examples\5_Composing.ahk
