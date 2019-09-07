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
    cBackground := "c" . "1d1f21"
    cCurrentLine := "c" . "282a2e"
    cSelection := "c" . "373b41"
    cForeground := "c" . "c5c8c6"
    cComment := "c" . "969896"
    cRed := "c" . "cc6666"
    cOrange := "c" . "de935f"
    cYellow := "c" . "f0c674"
    cGreen := "c" . "b5bd68"
    cAqua := "c" . "8abeb7"
    cBlue := "c" . "81a2be"
    cPurple := "c" . "b294bb"

    gui_control_options := "xm w220 " . cForeground . " -E0x200"
    ; -E0x200 removes border around Edit controls

    ; Initialize variable to keep track of the state of the GUI
    gui_state := "closed"

    ; Initialize search_urls as a variable set to zero
    search_urls := 0
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
    Gui, Color, 1d1f21, 282a2e
    Gui, +AlwaysOnTop -SysMenu +ToolWindow -caption +Border
    Gui, Font, s10, Segoe UI
    global level = 0
    Gui, Show,, myGUI
    global mainController
    mainController.ResetToRoot()
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
    eventBus.Emit("keyPressed", input)
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
    global eventBus
    eventBus.Emit(method, input)
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

; The callback function when the text changes in the input field.
InputCallback:
    Gui, Submit, NoHide  
    inputVar := getCurrentInputVar()
    Execute(%inputVar%, "keyPressed")
    if (result == true) {
        gui_destroy()
    }
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
    global gui_search_title

    gui_state = closed
    ; Forget search title variable so the next search does not re-use it
    ; in case the next search does not set its own:
    gui_search_title =
    for i in range(0, 10) {
        listViewVar := "listView" i
        %listViewVar% := 
    }

    ; Clear the tooltip
    Gosub, gui_tooltip_clear

    ; Hide GUI
    Gui, Destroy
    global eventBus
    eventBus.Emit("GuiClosed")

    ; Bring focus back to another window found on the desktop
    WinActivate
}

gui_change_title(message,color = "") {
    ; If parameter color is omitted, the message is assumed to be an error
    ; message, and given the color red.
    If color =
    {
        global cRed
        color := cRed
    }
    GuiControl,, gui_main_title, %message%
    Gui, Font, s11 %color%
    GuiControl, Font, gui_main_title
    Gui, Font, s10 cffffff ; reset
}

;-------------------------------------------------------------------------------
; SEARCH ENGINES
;-------------------------------------------------------------------------------
;
; gui_search_add_elements: Add GUI controls to allow typing of a search query.
;
gui_search_add_elements:
    Gui, Add, Text, %gui_control_options% %cYellow%, %gui_search_title%
    Gui, Add, Edit, %gui_control_options% %cYellow% vgui_SearchEdit -WantReturn
    Gui, Add, Button, x-10 y-10 w1 h1 +default ggui_SearchEnter ; hidden button
    GuiControl, Disable, Pedersen
    Gui, Show, AutoSize
    return

gui_search(url) {
    global
    if gui_state != search
    {
        gui_state = search
        ; if gui_state is "main", then we are coming from the main window and
        ; GUI elements for the search field have not yet been added.
        Gosub, gui_search_add_elements
    }

    ; Assign the url to a variable.
    ; The variables will have names search_url1, search_url2, ...

    search_urls := search_urls + 1
    search_url%search_urls% := url
}

gui_SearchEnter:
    Gui, Submit
    gui_destroy()
    query_safe := uriEncode(gui_SearchEdit)
    Loop, %search_urls%
    {
        StringReplace, search_final_url, search_url%A_Index%, REPLACEME, %query_safe%
        run %search_final_url%
    }
    search_urls := 0
    return

;-------------------------------------------------------------------------------
; TOOLTIP
; The tooltip shows all defined commands, along with a description of what
; each command does. It gets the description from the comments in UserCommands.ahk.
; The code was improved and fixed for Windows 10 with the help of schmimae.
;-------------------------------------------------------------------------------
gui_tooltip_clear:
    ToolTip
    return

gui_commandlibrary:
    ; hidden GUI used to pass font options to tooltip:
    CoordMode, Tooltip, Screen ; To make sure the tooltip coordinates is displayed according to the screen and not active window
    Gui, 2:Font,s10, Lucida Console
    Gui, 2:Add, Text, HwndhwndStatic

    tooltiptext =
    maxpadding = 0
    StringCaseSense, Off ; Matching to both if/If in the IfInString command below
    Loop, read, %A_ScriptDir%\UserCommands.ahk
    {
        ; search for the string If Pedersen =, but search for each word individually because spacing between words might not be consistent. (might be improved with regex)
        If Substr(A_LoopReadLine, 1, 1) != ";" ; Do not display commented commands
        {
            If A_LoopReadLine contains if
            {
                IfInString, A_LoopReadLine, Pedersen
                    IfInString, A_LoopReadLine, =
                    {
                        StringGetPos, setpos, A_LoopReadLine,=
                        StringTrimLeft, trimmed, A_LoopReadLine, setpos+1 ; trim everything that comes before the = sign
                        StringReplace, trimmed, trimmed, `%A_Space`%,{space}, All
                        tooltiptext .= trimmed
                        tooltiptext .= "`n"

                        ; The following is used to correct padding:
                        StringGetPos, commentpos, trimmed,`;
                        if (maxpadding < commentpos)
                            maxpadding := commentpos
                    }
            }
        }
    }
    tooltiptextpadded =
    Loop, Parse, tooltiptext,`n
    {
        line = %A_LoopField%
        StringGetPos, commentpos, line, `;
        spaces_to_insert := maxpadding - commentpos
        Loop, %spaces_to_insert%
        {
            StringReplace, line, line,`;,%A_Space%`;
        }
        tooltiptextpadded .= line
        tooltiptextpadded .= "`n"
    }
    Sort, tooltiptextpadded
    ToolTip %tooltiptextpadded%, 3, 3, 1
    return
