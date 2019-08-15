#Include %A_ScriptDir%\src\Environment\Opener.ahk

class CopyToClipboardOpener extends Opener {
    Default(argument) {
        Clipboard := argument
    }

    Website(website, environment) {
        Clipboard := website
    }

    Folder(folder, environment) {
        Clipboard := folder
    }

    File(file, environment) {
        Clipboard := file
    }
}
