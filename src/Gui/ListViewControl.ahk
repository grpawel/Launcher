#Include %A_ScriptDir%\src\Events\EventBus.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

class ListViewControl {
    _isSetup := false
    _eventBus := new EventBus()

    __New(gui, name, options) {
        this._gui := gui
        this._controlName := name
        this._options := options
    }

    Show() {
        if (!this._isSetup) {
            this._Setup()
            this._isSetup := true
        }
        guiName := this._gui.GetName()
        controlName := this._controlName
        GuiControl, %guiName%: Show, %controlName%
    }

    _Setup() {
        local guiName := this._gui.GetName()
        local controlName := this._controlName
        local style := this._GetStyle(this._options)
        local doubleClickHandler := this._OnRowDoubleClicked.Bind(this)
        
        Gui, %guiName%: Default
        ; Initial height must be 0, 
        ; because next input position is calculated
        ; using previous control initial position, ignoring further changes.
        ; TODO: remove margin around
        Gui, %guiName%: Add, ListView, h0 -Hdr -Multi %style% v%controlName%, Command|Description
        GuiControl, %guiName%: +g, %controlName%, %doubleClickHandler%
        LV_ModifyCol()
        GuiControl, %guiName%: Move, %controlName%, h150
    }
    
    _GetStyle(options) {
        position := "xm"
        if (options.position == "right") {
            position := "x+m ym"
        }
        return Join([ " -E0x200" ; no borders
                    , position
                    , "w" . options.width
                    , "c" . options.textColor ]
                , " ")
    }

    Populate(rows) {
        guiName := this._gui.GetName()
        controlName := this._controlName
        GuiControl, %guiName%: -Redraw, %controlName%
        rows_total := rows.Length()
        GuiControl, %guiName%: Count%rows_total%, %controlName%
        for index, row in rows {
            LV_Add("", row[1], row[2])
        }
        LV_ModifyCol()
        GuiControl, %guiName%: +Redraw, %controlName%
    }

    RemoveRows() {
        LV_Delete()
    }

    Hide() {
        guiName := this._gui.GetName()
        controlName := this._controlName
        GuiControl, %guiName%: Hide, %controlName%
    }

    Destroy() {
        ; Break circular references (https://www.autohotkey.com/docs/Objects.htm#Circular_References).
        this._gui := ""
        this._eventBus.UnsubscribeAll()
        this._eventBus := ""
    }

    Disable() {
        this.Hide()
    }

    _OnRowDoubleClicked() {
        if (A_GuiEvent == "DoubleClick") {
            LV_GetText(rowText, A_EventInfo)
            this._eventBus.Emit("rowSelected", rowText)
        }
    }

    _OnReturnPressed() {
        selectedRowNumber := LV_GetNext()
        LV_GetText(rowText, selectedRowNumber)
        this._eventBus.Emit("rowSelected", rowText)
    }

    ; Payload: text from first column
    SubscribeRowSelected(callback, options = "") {
        this._eventBus.Subscribe("rowSelected", callback, options)
    }

    NotifyReturnPressed() {
        this._OnReturnPressed()
    }
}
