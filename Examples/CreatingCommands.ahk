; This example shows ways of creating commands.
; You should read the code, testing in gui is not required.

; To run this example run `RunExample.ahk` from parent directory and select "2. Creating commands".

; If you want to use this file with your own commands:
;  1. Copy this file to main directory (the one containing `src`, `Examples` and other folders).
;  2. Remove all lines with "; only-for-demo" comments.
;  3. Add your commands.
; Rest of the file contains everyting you need.



#Include %A_ScriptDir%\src\IncludeAll.ahk

CreatingCommands:                                           ; only-for-demo
    MsgBox, Press`nCtrl + Shift + /`nto open GUI.           ; only-for-demo

    commands := new CommandSet().SetDescription("Creating commands")
    
    ; Add command using `AddCommand` method:
    commands.AddCommand("goo", new Open("https://google.com").SetDescription("Google"))

    ; Store command in a variable and add it multiple times:
    openChrome := new Open("chrome")
    commands.AddCommand("chr", openChrome)
    ; Note that `SetDescription` method modifies the object - description of "chr" command is also changed.
    commands.AddCommand("browser", openChrome.SetDescription("Chrome"))
    ; You can prevent that by using "Duplicate" method - "chr" and "browser" would still have their old description.
    commands.AddCommand("web", openChrome.Duplicate().SetDescription("Open web browser"))

    ; Add commands from an object:
    websites := { "duck": new Open("https://duckduckgo.com")
                , "ama": new Open("https://amazon.com") }
    commands.AddCommands(websites)
    ; Be careful where you place the comma (,) - it has to be at the start of new line, not at the end of previous.
    ; See https://www.autohotkey.com/docs/Scripts.htm#continuation         

    ; Get specific command:
    openDDG := commands.GetCommand("duck")
    commands.AddCommand("ddg", openDDG)

    ; Chain methods:
    commands.AddCommand("calc", new Open("calc"))
            .AddCommand("pai", new Open("C:\Windows\system32\mspaint.exe").SetDescription("MS Paint"))
    
    
    ; Use command factory:
    ; Instead of `new Open(...)`, you can call method on the factory: `_.Open(...)`
    ; By doing that your script is a little bit shorter.
    _ := new CommandFactory()
    commands.AddCommand("note", _.Open("notepad"))
    ; If you make a typo and the command is wrong, you will be notified. `new` fails silently.
    ; Uncomment and run example to test that:
    /*
    commands.AddCommand("err1", _.ThisCommandDoesNotExist())
    commands.AddCommand("err2", new ThisCommandDoesNotExist())
    */
    
    ; Create your own command:
    commands.AddCommand("own", _.YourOwnCommand("someewheeeeere over the rainbow").SetDescription("Your Own Command"))

    ; Use your own function:
    ; `FunctionToCommand` command takes a function object (see https://www.autohotkey.com/docs/objects/Functor.htm)
    ; and calls it.
    commands.AddCommand("msg", _.FunctionToCommand(Func("ShowSomeMessages")).SetDescription(""))


    contr := new Controller(new Environment(), new Gui())
    contr.SetRootCommand(WithHelpOpened(commands))

    activeExample := "creatingCommands"                     ; only-for-demo
    return                                                  ; only-for-demo

; Commands should extend `Command` class. This gives description, tags and other functionalities.
; The command will be picked up by `CommandFactory`.
class YourOwnCommand extends Command {
    ; Constructor. Use it to pass some configuration to the command.
    __New(something) {
        this._something := something
        ; Default description could be set like this:
        /*
        this._description := "default description"
        */
    }

    ; `Run` method is called when you select the command.
    ; Parameters are `contr` - `Controller` object - your "window to the world"
    ; and "context", which passes some additional information.
    Run(contr, context) {
        ; Gui is hidden after a command is finished. 
        ; By default MsgBoxes would be covered up by gui window, so we want to destroy the gui window first.
        contr.GetGui().Destroy()

        MsgBox % "Something is equal to: `n" this._something
    }
}

; Function arguments are same as those in `Command.Run` method.
ShowSomeMessages(contr, context) {
    contr.GetGui().Destroy()
    MsgBox % "Running your own function"
    MsgBox % "Do whatever in it"
}



#If (activeExample == "creatingCommands")                   ; only-for-demo
{                                                           ; only-for-demo
    +^/::
        contr.Execute()
        return
}                                                           ; only-for-demo

#Include %A_ScriptDir%\src\Gui\GuiEscapes.ahk