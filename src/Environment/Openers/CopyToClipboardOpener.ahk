#Include %A_ScriptDir%\src\Environment\Opener.ahk

class CopyToClipboardOpener extends Opener {
    Open(argument) {
        Clipboard := argument
    }
}
