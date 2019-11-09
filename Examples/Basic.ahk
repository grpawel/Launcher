; This example shows basic functionality. Try out GUI and read code in this file.

; To run this example run `RunExample.ahk` from parent directory and select "1. Basic".

; If you want to use this file with your own commands:
;  1. Copy this file to main directory (the one containing `src`, `Examples` and other folders).
;  2. Remove all lines with "; only-for-demo" comments.
;  3. Add your commands.
; Rest of the file contains everyting you need.



; Include all necessary files from the project.
#Include %A_ScriptDir%\src\IncludeAll.ahk

Basic:                                                          ; only-for-demo
    MsgBox, Press`nCtrl + Shift + /`nto open GUI.               ; only-for-demo

    ; CommandSet stores and matches your commands.
    ; It shows an input field in GUI,
    ; then tries to match what you write in the input with a command.
    commands := new CommandSet().SetDescription("Basic example")
    
    ; Add command: "when user types `goo`, open https://google.com"
    commands.AddCommand("goo", new Open("https://google.com").SetDescription("Google"))
    commands.AddCommand("ama", new Open("https://amazon.com"))
    ; You can open websites, programs, files and other things.
    commands.AddCommand("calc", new Open("calc"))
    commands.AddCommand("hosts", new Open("C:\Windows\system32\drivers\etc\hosts").SetDescription("hosts file"))

    ; Add commands in a loop. These would open folders for drives in your computer.
    for letter in RangeAscii("C", "F") {
        commands.AddCommand(letter "/", new Open(letter ":\"))
    }

    ; Typing `?` will show or hide help - side window listing all available commands.
    commands.AddCommand("?", new Help(commands))
    ; Typing `rel` will reload script. Reloading is necessary when you added or removed a command in a file.
    commands.AddCommand("rel", new Reload())

    ; `WithHelpOpened` returns the same CommandSet, but it will have Help opened by default.
    commands := WithHelpOpened(commands)
    ; These two next lines are required for everything to work.
    contr := new Controller(new Environment(), new Gui())
    contr.SetRootCommand(commands)

    activeExample := "basic"                                    ; only-for-demo
    return                                                      ; only-for-demo

#If (activeExample == "basic")                                  ; only-for-demo
{                                                               ; only-for-demo
    ; Ctrl + Shift + /
    +^/::
        ; Run command given to controller - CommandSet `commands`, which shows input field.
        contr.Execute()
        return
}                                                               ; only-for-demo

; This file allows Escape key to close GUI.
#Include %A_ScriptDir%\src\Gui\GuiEscapes.ahk