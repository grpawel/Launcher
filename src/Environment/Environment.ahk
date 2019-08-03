#Include %A_ScriptDir%\src\Environment\Browser.ahk

class Environment {
    _browser := new Browser()

    browser { 
        get {
            return this._browser
        }
    }
}