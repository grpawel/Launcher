#Include %A_ScriptDir%\src\Executables\Executable.ahk

class WebSearch extends Executable {
    __New(urlTemplate, title) {
        this._urlTemplate := urlTemplate
        this.title := title
    }
    Execute(query) {
        url := StrReplace(this._urlTemplate, "REPLACEME", query)
        run, %url%
        return true
    }
}