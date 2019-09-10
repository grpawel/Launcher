; Created by Asger Juul Brunshøj

; Note: Save with encoding UTF-8 with BOM if possible.
; I had issues with special characters like in ¯\_(ツ)_/¯ that wouldn't work otherwise.
; Notepad will save UTF-8 files with BOM automatically (even though it does not say so).
; Some editors however save without BOM, and then special characters look messed up in the AHK GUI.

;-------------------------------------------------------------------------------
; AUTO EXECUTE
;-------------------------------------------------------------------------------
gui_autoexecute:
    ; Tomorrow Night Color Definitions:

    gui_control_options := "xm w220 " . (Colors.foreground) . " -E0x200"
    ; -E0x200 removes border around Edit controls

    ; Initialize variable to keep track of the state of the GUI
    gui_state := "closed"

    return

;-------------------------------------------------------------------------------
; LAUNCH GUI
;-------------------------------------------------------------------------------
CapsLock & Space::
gui_spawn:
    if gui_state != closed
    {
        ; If the GUI is already open, close it.
        gui_destroy()
        return
    }

    gui_state = main
    Gui, Margin, 16, 16
    colorBackground := Colors.background
    colorCurrentLine := Colors.currentLine
    Gui, Color, %colorBackground%, %colorCurrentLine%
    Gui, +AlwaysOnTop -SysMenu +ToolWindow -caption +Border
    Gui, Font, s10, Segoe UI
    global level = 0
    Gui, Show,, myGUI
    global mainController
    mainController.RunRootCommand()
    return


GuiAddInput() {
    global ; global gui_control_options does not work
    level += 1
    local title := mainController.GetTitle()
    local previousInputVar := "input" (level - 1)
    local currentInputVar := getCurrentInputVar()
    if (title <> "") {
        Gui, Add, Text, %gui_control_options% vTitle%level%, %title%
    }
    Gui, Add, Edit, %gui_control_options% v%currentInputVar% gKeyPressed -WantReturn
    Gui, Add, Button, x-10 y-10 w1 h1 v%currentInputVar%Button +default gReturnPressed
    GuiControl, Disable, %previousInputVar%
    GuiControl, Disable, %previousInputVar%Button
    GuiControl, Focus, %currentInputVar%
    Gui, Show, AutoSize
    return
}

GuiSetInput(input) {
    global
    inputVar := "input" level
    GuiControl, Text, %inputVar%, %input%
    globalEventBus.Emit("keyPressed", input)
}

GuiShowListView() {
    global
    local listViewVar := "listView" level
    try {
        ; initial height must be 0, because next input positions itself with initial position regardless of changes
        ; so adding next input creates empty space where listview is hidden, even if listview height is changed to 0
        ; TODO: remove margin around
        Gui, Add, ListView, h0 -Hdr %gui_control_options% gHelpGui v%listViewVar%, Command|Title
        LV_ModifyCol()
    } catch e {
        GuiControl, Show, %listViewVar%
    }
    GuiControl, Move, %listViewVar%, h150
    Gui, Show, AutoSize 
    return false
}

GuiPopulateListView(rows) {
    for index, row in rows {
        LV_Add("", row[1], row[2])
    }
    LV_ModifyCol()
}

GuiRemoveRowsListView() {
    LV_Delete()
}

GuiRemoveListView() {
    global level 
    listViewVar := "listView" level
    GuiControl, Hide, %listViewVar%
    Gui, Show, AutoSize
    return false
}

HelpGui() {
    if (A_GuiEvent = "DoubleClick") {
        LV_GetText(RowText, A_EventInfo)
        Execute(RowText, "rowDoubleClicked")
    }
    return
}

getCurrentInputVar() {
    global level
    return "input" level
}

Execute(input, method) {
    global mainController
    result := mainController.Execute(input, method)
    global globalEventBus
    globalEventBus.Emit(method, input)
    if (result == true) {
        gui_destroy()
    }
    return
}
;-------------------------------------------------------------------------------
; GUI FUNCTIONS AND SUBROUTINES
;-------------------------------------------------------------------------------
; Automatically triggered on Escape key:
GuiEscape:
    gui_destroy()
    return

KeyPressed:
    Gui, Submit, NoHide
    inputVar := getCurrentInputVar()
    Execute(%inputVar%, "keyPressed")
    return

ReturnPressed:
    Gui, Submit, NoHide
    inputVar := getCurrentInputVar()
    Execute(%inputVar%, "returnPressed")
    return
;
; gui_destroy: Destroy the GUI after use.
;
#WinActivateForce
gui_destroy() {
    global gui_state

    gui_state = closed
    for i in range(0, 10) {
        listViewVar := "listView" i
        %listViewVar% := 
    }
    ; Hide GUI
    Gui, Destroy
    global globalEventBus
    globalEventBus.Emit("GuiClosed")

    ; Bring focus back to another window found on the desktop
    WinActivate
}
