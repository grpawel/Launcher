#Include %A_ScriptDir%\src\Commands\Command.ahk

class RunOtherScript extends Command {
    ; command = "open" | "close" | "toggle"
    __New(command, name = "", path = "") {
        this._command := command
        this._name := name
        this._path := path
        this._description := command " " name " script"
    }

    Run(contr, context) {
        name := GetValue(this._name, contr, context)
        path := GetValue(this._path, contr, context)

        if (this._command == "open") {
            this._Open(path)
        } else if (this._command == "close") {
            this._Close(name)
        } else if (this._command == "toggle") {
            this._Toggle(name, path)
        }
    }

    _Toggle(name, path) {
        if (this._IsScriptRunning(name)) {
            this._Close(name)
        } else {
            this._Open(path)
        }
    }

    _Open(path) {
        Run, %path%
    }

    _Close(name) {
        DetectHiddenWindows On
        SetTitleMatchMode RegEx
        IfWinExist, i)%name%.* ahk_class AutoHotkey
        {
            WinClose
            WinWaitClose, i)%name%.* ahk_class AutoHotkey, , 2
            if (ErrorLevel) {
                MsgBox Unable to close %name%, error:%ErrorLevel%
                return false
            } else
                return true
        } else {
            MsgBox, script %name% not found
            return false
        }
    }

    _IsScriptRunning(name) {
        DetectHiddenWindows, On
        SetTitleMatchMode, 2
        ;SetTitleMatchMode, Slow
        IfWinExist, %name%
        {
            return true
        }
        return false
    }
}
