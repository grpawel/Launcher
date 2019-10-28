examples := [ { id: 1, proc: "Basic", name: "Basic" } ]

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
