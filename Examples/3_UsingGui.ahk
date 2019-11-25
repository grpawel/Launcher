; This example shows how to select a command in gui.
; There are multiple subexamples. Each one shows different functionality or setting.


; To run this example run `RunExample.ahk` from parent directory and select "3. Using GUI".

; If you want to use this file with your own commands:
;  1. Copy this file to main directory (the one containing `src`, `Examples` and other folders).
;  2. Remove all lines with "; only-for-demo" comments.
;  3. Add your commands.
; Rest of the file contains everyting you need.



#Include %A_ScriptDir%\src\IncludeAll.ahk

UsingGuiExample:                                            ; only-for-demo
    MsgBox, Press`nCtrl + Shift + /`nto open GUI.           ; only-for-demo

    commands := new CommandSet().SetDescription("How to select a command")
    

    doubleClick := new CommandSet()
    doubleClick.Add("goog", new Open("https://google.com"))
    doubleClick.Add("good", new Open("https://goodreads.com"))
    doubleClick.Add("ama", new Open("https://amazon.com"))
    doubleClickExplanation := new Sequence([ new ShowMessage("You can select command using list on the right in many ways:"
                                                            , { textColor: Colors.YELLOW })
                                           , new ShowMessage("1. Press Tab, select with up/down arrow keys and press Enter.`n"
                                                             . "2. Press Tab, type something (eg. ""g"") to select and press Enter.`n"
                                                             . "3. Double click on item in the list."
                                                            , { textColor: Colors.AQUA }) ])    
    ; `Sequence()` runs all given commands.
    ; Here we reset GUI to remove what was shown before, show message and show input for doubleClick command set (with help).
    ; Help shows list of commands from given `CommandSet` object.
    commands.Add("1", new Sequence([ new ResetGui()
                                   , doubleClickExplanation
                                   , WithHelp(doubleClick) ])
                           .SetDescription("Use the list to the right"))


    ; `{ typingMatch: "exact" }` is the default setting. It is used when you do not specify anything.
    exact := new CommandSet( { typingMatch: "exact" })
    exact.Add("google", new Open("https://google.com"))
    exact.Add("goodreads", new Open("https://goodreads.com"))
    exact.Add("amazon", new Open("https://amazon.com"))
    exactExplanation := new Sequence([ new ShowMessage("By default you have to type whole key."
                                                      , { textColor: Colors.YELLOW })
                                     , new ShowMessage("Type ""goodreads"" to run ""goodreads""."
                                                      , { textColor: Colors.AQUA }) ])
    commands.Add("2", new Sequence([ new ResetGui()
                                   , exactExplanation
                                   , exact
                                   , new Help(exact) ])
                           .SetDescription("Type whole key"))


    immediate := new CommandSet( { typingMatch: "immediate" })
    immediate.Add("google", new Open("https://google.com"))
    immediate.Add("goodreads", new Open("https://goodreads.com"))
    immediate.Add("amazon", new Open("https://amazon.com"))
    immediateExplanation := new Sequence([ new ShowMessage("CommandSet can be configured to run a command immediately"
                                                           . "when exactly one command key starts with what you've typed."
                                                          , { textColor: Colors.YELLOW })
                                         , new ShowMessage("Type ""good"" to run ""goodreads"".`n"
                                                           . "Type ""a"" to run ""amazon""."
                                                          , { textColor: Colors.AQUA }) ])
    ; Note that we sometimes use `Sequence([..., comset, new Help(comset)])`
    ; and sometimes `Sequence([..., WithHelp(comset)])`. 
    ; These have the same result.
    commands.Add("3", new Sequence([ new ResetGui()
                                   , immediateExplanation
                                   , WithHelp(immediate) ])
                           .SetDescription("Match immediately"))


    atLeast := new CommandSet( { typingMatch: ["atLeast", 3]})
    atLeast.Add("google", new Open("https://google.com"))
    atLeast.Add("goodreads", new Open("https://goodreads.com"))
    atLeast.Add("amazon", new Open("https://amazon.com"))
    atLeast.Add("c", new Open("calc"))
    atLeastExplanation := new Sequence([ new ShowMessage( "CommandSet can be configured to match a command immediately when only one matches what you typed, "
                                                          . "but if you typed at least N (N=3 here) characters.`n"
                                                          . "If command key is shorter than N, it still works."
                                                        , { textColor: Colors.YELLOW })
                                       , new ShowMessage("Type ""ama"" to run ""amazon"".`n"
                                                         . "Type ""good"" to open ""goodreads"" (""goo"" matches 2 commands).`n"
                                                         . "Type ""c"" to open calc."
                                                        , { textColor: Colors.AQUA }) ])
    commands.Add("4", new Sequence([ new ResetGui()
                                   , atLeastExplanation
                                   , atLeast
                                   , new Help(atLeast) ])
                           .SetDescription("Match at least N characters"))


    enterShortcut := new CommandSet( { typingMatch: "exact" })
    enterShortcut.Add("goooooooooooooooogle", new Open("https://google.com"))
    enterShortcut.Add("goodreads", new Open("https://goodreads.com"))
    enterShortcut.Add("amazon", new Open("https://amazon.com"))
    enterShortcut.Add("c", new Open("calc"))
    enterShortcutExplanation := new Sequence([ new ShowMessage("This example is configured as subexample 2, where you had to type whole key.`n"
                                                               . "There's a shortcut for that: press Enter when a single command matches.`n"
                                                               . "If you want to commands matched only when you press Return, there's setting for that.`n"
                                                               ; That setting is `{ typingMatch: "onlyReturn" }`.
                                                              , { textColor: Colors.YELLOW })
                                             , new ShowMessage("Type ""goooo"" and press Enter to run the command."
                                                              , { textColor: Colors.AQUA }) ])
    commands.Add("5", new Sequence([ new ResetGui()
                                   , enterShortcutExplanation
                                   , WithHelp(enterShortcut) ])
                           .SetDescription("Use Enter to select"))


    overlapping := new CommandSet()
    overlapping.Add("wiki", new Open("https://wikipedia.org"))
    overlapping.Add("wikimedia", new Open("https://commons.wikimedia.org/"))
    overlappingExplanation := new ShowMessage("If you have two commands where one key is a beginning of the other,`n"
                                              . "the only way to select longer one is by using the list on the right.`n"
                                             , { textColor: Colors.YELLOW })
    commands.Add("6", new Sequence([ new ResetGui()
                                   , overlappingExplanation
                                   , WithHelp(overlapping) ])
                           .SetDescription("Overlapping command keys"))

    commands.Add("rel", new Reload())
    contr := new Controller(new Environment(), new Gui())
    contr.SetRootCommand(WithHelp(commands))

    activeExample := "usingGui"                             ; only-for-demo
    return                                                  ; only-for-demo

#If (activeExample == "usingGui")                           ; only-for-demo
{                                                           ; only-for-demo
    +^/::
        contr.Execute()
        return
}                                                           ; only-for-demo

#Include %A_ScriptDir%\src\Gui\GuiEscapes.ahk
