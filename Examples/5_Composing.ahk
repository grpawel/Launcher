; This example shows how to group commands and their uses.

; To run this example run `RunExample.ahk` from parent directory and select "5. Composing".

; If you want to use this file with your own commands:
;  1. Copy this file to main directory (the one containing `src`, `Examples` and other folders).
;  2. Remove all lines with "; only-for-demo" comments.
;  3. Add your commands.
; Rest of the file contains everyting you need.



#Include %A_ScriptDir%\src\IncludeAll.ahk

ComposingExample:                                           ; only-for-demo
    MsgBox, Press`nCtrl + Shift + /`nto open GUI.           ; only-for-demo

    commands := new CommandSet().SetDescription("Composing")
    commands := WithHelpOpened(commands)



    ; ====== 1. COMMAND SETS ======

    ; ------ 1.1 Nested CommandSets ------

    ; There can be multiple CommandSets called from one another.
    ; Use them to group commands in smaller sets:

    entertainment := new CommandSet().SetDescription("Entertainment")
    entertainment.Add("yt", new Web("https://youtube.com"))
    entertainment.Add("red", new Web("https://reddit.com"))
    entertainment.Add("/", new Search("https://reddit.com/r/REPLACEME").SetDescription("Subreddit"))
    commands.Add("nested", WithHelpOpened(entertainment))

    ; There's no limit to depth of nesting and loops are allowed:
    commands.Add("com", commands)

    ; ------ 1.2 Observing CommandSets ------

    ; CommandSet can track changes in other CommandSets and update itself.
    observed := new CommandSet()
    observed.Add("goo", new Web("google.com").AddTags("searchWebsite"))
    observed.Add("ddg", new Web("duckduckgo.com").AddTags("searchWebsite"))
    observed.Add("msg", new ShowMessage("some message").AddTags("message"))

    ; Here we create two CommandSets containing all commands with "searchWebsite" tag:
    filtering := observed.Filter(HasTag("searchWebsite"))
    observing := new CommandSet().Observe(observed, new Pipeline().Filter(HasTag("searchWebsite")))

    ; After adding new command to `observed` it will appear in `observed`, but not in `observing`:
    observed.Add("bing", new Web("bing.com").AddTags("searchWebsite"))
    ; Removed commands will be also removed from `observed` but not from "filtered":
    observed.Remove("goo")

    ; You can still add commands to `observing` as usual.
    ; `observing` can track changes from multiple CommandSets.

    commands.Add("obs", WithHelpOpened(new CommandSet()
                         .Add("0", WithHelpOpened(observed).SetDescription("All commands"))
                         .Add("1", WithHelpOpened(filtering).SetDescription("Filtered"))
                         .Add("2", WithHelpOpened(observing).SetDescription("Observed"))
                         .SetDescription("1.2 Observing CommandSets") ))



    ; ====== 2. GROUPING COMMANDS =======

    ; ------ 2.1 Sequence -------
    ; Sequence allows you to run multiple commands one after another, as seen in example 3. Using GUI.

    commands.Add("s1", new Sequence([ new Web("google.com")
                                    , new Web("duckduckgo.com")
                                    , new Web("bing.com") ])
                            .SetDescription("Open search engines"))

    ; Open three inputs. Should open only one website depending where you press Enter.
    commands.Add("s2", new Sequence([ new Search("google.com/search?q=REPLACEME").SetDescription("Google")
                                    , new Search("duckduckgo.com/?q=REPLACEME").SetDescription("DuckDuckGo")
                                    , new Search("bing.com/search?q=REPLACEME").SetDescription("Bing") ])
                            .SetDescription("Search in selected engine"))
    

    ; Show message in multiple colors:
    commands.Add("mes", new Sequence([ new ShowMessage("This is yellow.", { textColor: "FFFF00" })
                                     , new ShowMessage("This is aqua.", { textColor: Colors.AQUA }) ])
                             .SetDescription("Show colorful message"))

    ; Commands in sequence can interact with each other.
    ; Open input for searching and type something in:
    commands.Add("ahk", new Sequence([ new Search("google.com/search?q=REPLACEME")
                                     , new TypeText("AutoHotkey ", { when: "immediate" })])
                             .SetDescription("Search for AutoHotkey"))

    ; Reset gui and then do something:
    commands.Add("reset", new Sequence([ new ResetGui()
                                       , new ShowMessage("Gui was reset")
                                       , commands ])
                               .SetDescription("Reset gui and start over"))

    
    ; ------ 2.2 Choice -------

    ; `Choice` command allows you to run one of commands based on output of some function.
    ; First argument is a function object (see https://www.autohotkey.com/docs/objects/Functor.htm).
    ; This function will be called with controller, context and second argument from Choice.
    ; Second argument is map from possible values of function to commands.
    ; Third optional argument is default command, run when function returned something not in the map.

    ; Run random command from "s2" command:
    commands.Add("randomsearch", new Choice(Func("RandomChoice"), commands.Get("s2").GetAll())
                                      .SetDescription("Search in random engine"))

    Goto ComposingExample_SkipDefinition2_2_a               ; only-for-demo

; Returns random key from given map
RandomChoice(contr, context, choices) {
    return RandomKey(choices)
}

ComposingExample_SkipDefinition2_2_a:                       ; only-for-demo
    ; Show msgbox and act accordingly:
    ; Note that in `{ true: ...}` true is treated as string, so we had to use `1` instead 
    commands.Add("red", new Choice(Func("DoYouReally")
                                  , { 1: new Web("reddit.com") 
                                    , 0: new ShowMessage("You did not open Reddit") })
                             .SetDescription("Reddit?"))

    ; Options do not have to be simple commands:
    commands.Add("ent", new Choice(Func("DoYouReally")
                                  , { 1: new Sequence([ new ShowMessage("Time for fun!"), WithHelpOpened(entertainment) ])
                                    , 0: new ShowMessage("You did not entertain yourself") })
                             .SetDescription("Entertainment?"))

    Goto ComposingExample_SkipDefinition2_2_b               ; only-for-demo

DoYouReally(contr) {
    contr.GetGui().Destroy()
    MsgBox, 0x124, Question, Do you really want to open?
    IfMsgBox, Yes
        return true
    return false
}

ComposingExample_SkipDefinition2_2_b:                       ; only-for-demo
    ; Show browser settings depending on current browser:
    ; `GetEnvironmentSetting` already returns Func object.
    commands.Add("sett", new Choice(GetEnvironmentSetting("browser")
                                   , { "C:\Program Files\Mozilla Firefox\firefox.exe": new Web("about:config")
                                     , "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
                                       ; Apparently Chrome does not allow to open internal pages from outside.
                                       ; Workaround:
                                       : new Sequence([ new Web("thisprobablydoesnotexistqwerty.com")
                                                      , new ResetGui()
                                                      , new SleepMs(1000)
                                                      , new TypeText("{F6}")
                                                      , new SleepMs(1000)
                                                      , new TypeText("chrome://flags{Enter}") ]) })
                         .SetDescription("Show browser settings"))

    ; Add a custom setting and do different things based on that:
    commands.Add("opta", new ChangeEnvironment({ settings: { customOption: "A"}}).SetDescription("Change option to A"))
    commands.Add("optb", new ChangeEnvironment({ settings: { customOption: "B"}}).SetDescription("Change option to B"))
    commands.Add("optc", new ChangeEnvironment({ settings: { customOption: "C"}}).SetDescription("Change option to C"))

    commands.Add("option", new Choice(GetEnvironmentSetting("customOption")
                                     , { "A": new ShowMessage("Current option is A")
                                       , "B": new ShowMessage("B, but this message could be a Sequence or CommandSet")
                                       , "C": new ShowMessage("Option is C or default") }
                                     , { defaultKey: "C" })
                             .SetDescription("Do things based on current option"))

    ; ------ 2.3 ShareInputs ------

    ; `ShareInputs` command allows you to share inputs between commands.
    ; This way you can for example search using many sites at once.

    ; How it works:
    ; First command in array creates its gui controls.
    ; Next command tries to create its own controls, but instead receives already existing ones.
    ; If command needs more controls of some type than already exist, not existing ones will be created.

    ; Share input field with all searches - will open three websites.
    ; `ShowMessage` is used so that first `Search` won't add its default text.
    ; Option `noDestroyCommands` tells `ShareInputs` how many commands won't attempt to destroy gui,
    ; because by default it will wait for all of them to destroy gui.
    commands.Add("s3", new ShareControls([ new ShowMessage("Use multiple search engines")
                                         , new Search("google.com/search?q=REPLACEME")
                                         , new Search("duckduckgo.com/?q=REPLACEME")
                                         , new Search("bing.com/search?q=REPLACEME")]
                                         , { noDestroyCommands: 1 })
                             .SetDescription("Search multiple sites at once"))

    ; Share input between `Search` and `CommandSet`:
    ; When `searchHotstrings` picks up input, it will remove the key and fill expanded string.
    ; `destroyGuiAfter: "never"` causes `CommandSet` to never destroy the gui,
    ; so we must tell `ShareControls` that one commmand won't attempt to destroy gui
    ; in order to do that properly (option `noDestroyCommands: 1`)
    ; `CommandSet` would also disable its input, `allowDisabling: false` prevents that.
    searchHotstrings := new CommandSet({ destroyGuiAfter: "never" })
    searchHotstrings.Add("ahk", new TypeText("{Backspace}{Backspace}{Backspace}AutoHotkey ", { when: "immediate" }).SetDescription("AutoHotkey"))
    searchHotstrings.Add("w10", new TypeText("{Backspace}{Backspace}{Backspace}Windows 10 ", { when: "immediate" }).SetDescription("Windows 10"))

    commands.Add("s4", new ShareControls([ new Search("google.com/search?q=REPLACEME").SetDescription("Search Google")
                                         , searchHotstrings ]
                                         , { allowDisabling: true, noDestroyCommands: 1 })
                             .SetDescription("Search with hotstrings"))

    ; Combine previous examples and also show list of available hotstrings:
    ; First `ShowMessage` from sequence won't show a message, because there's already one from first `ShowMessage`.
    ; There's no more text controls, so second `ShowMessage` shows its text.
    commands.Add("s5", new ShareControls([ new ShowMessage("Use multiple search engines")
                                         , new Search("google.com/search?q=REPLACEME")
                                         , new Search("duckduckgo.com/?q=REPLACEME")
                                         , new Search("bing.com/search?q=REPLACEME")
                                         , WithHelpOpened(searchHotstrings) ]
                                         , { allowDisabling: false, noDestroyCommands: 2 })
                             .SetDescription("Search multiple sites with visible hotstrings"))



    ; ====== 3. FUNCTIONS =======

    ; ------ 3.1 Predicates ------
    ; Predicate is a function that returns true or false for its argument.
    ; You can find them in src/Functions/Predicates.ahk file.
    
    ; They are used for example in filtering CommandSets.
    predicateExamples := WithHelpOpened(new CommandSet()).SetDescription("3.1. Predicates examples")
    commands.Add("pred", predicateExamples)

    ; Some sample commands 
    sampleCommands := new CommandSet()
    sampleCommands.Add("google", new Web("google.com")
                                      .SetDescription("Web, tags: [""search""]")
                                      .AddTags(["search"]))
    sampleCommands.Add("web", new Web("youtube.com")
                                  .SetDescription("Web, tags: [""entertainment""]")
                                  .AddTags("entertainment"))
    sampleCommands.Add("search", new Search("https://www.youtube.com/results?search_query=REPLACEME")
                                      .SetDescription("Search, tags: [""entertainment"", ""search""]")
                                      .AddTags(["entertainment", "search"]))
    sampleCommands.Add("set", new CommandSet()
                                   .AddMany({ "web": webYoutube
                                            , "search": searchYoutube })
                                    .SetDescription("CommandSet, tags: []"))
    sampleCommands.Add("withHelp", WithHelpOpened(new CommandSet())
                                    .SetDescription("WithHelpOpened(CommandSet), tags: []"))


    predicateExamples.Add("0", sampleCommands.SetDescription("All commands"))

    ; `IsClass()` returns function that checks if its argument has a specific class.
    ; `.Filter()` takes such function and returns new CommandSet
    ; with all commands for which the function returned true.
    predicateExamples.Add("1", sampleCommands.Filter(IsClass("Web"))
                                .SetDescription("Commands with ""Web"" class"
                                                . "`n=`n``IsClass(""Web"")``"))

    predicateExamples.Add("2", sampleCommands.Filter(IsClass(["Web", "Search"]))
                                .SetDescription("Commands with ""Web"" or ""Search"" classes"
                                               . "`n=`n``IsClass([""Web"", ""Search""]``"))

    ; Here you would expect "set" and "withHelp" commands, but there's only "set" command.
    ; `IsClass` does not work for wrapped commands, like WithHelpOpened(comSet).
    ; Technically `WithHelpOpened(new CommandSet())` returns `MethodDecorator` object,
    ; so checking `__Class` does not work here.
    predicateExamples.Add("3", sampleCommands.Filter(IsClass("CommandSet"))
                                .SetDescription("Commands with ""CommandSet"" class"
                                                      . "`n=`n``IsClass(""CommandSet"")``"))
    ; Instead always use `IsCommand` for filtering commands which works as expected.
    ; 4. Get `CommandSet` commands, no matter if wrapped:
    predicateExamples.Add("4", sampleCommands.Filter(IsCommand("CommandSet"))
                                .SetDescription("""CommandSet"" commands"
                                                . "`n=`n``IsCommand(""CommandSet"")``"))

    ; `HasTag()` checks if command has any of specified tags:
    predicateExamples.Add("5", sampleCommands.Filter(HasTag("entertainment"))
                                .SetDescription("Commands having ""entertainment"" tag"
                                                . "`n=`n``HasTag(""entertainment"")``"))
    predicateExamples.Add("6", sampleCommands.Filter(HasTag(["tag1", "tag2", "entertainment"]))
                                .SetDescription("Commands having at least one of specified tags"
                                                . "`n=`n``HasTag([""tag1"", ""tag2"", ""entertainment""])``"))

    ; `CommandSet` does not report tags from its commands.
    ; There's no simple solution for filtering nested hierarchies.
    
    ; You can combine predicates using `OrFunc` and `AndFunc` to create complex ones:
    predicateExamples.Add("7", sampleCommands.Filter(AndFunc(HasTag("entertainment"), IsCommand("Web")))
                                .SetDescription("""Web"" commands having ""entertainment"" tag"
                                                . "`n=`n``AndFunc(HasTag(""entertainment""), IsCommand(""Web""))``"))

    predicateExamples.Add("8", sampleCommands.Filter(AndFunc(HasTag("entertainment"), HasTag("search")))
                                .SetDescription("Commands having ""entertainment"" and ""search"" tags"
                                                . "`n=`n``AndFunc(HasTag(""entertainment""), HasTag(""search""))``"))

    ; Add help and "back" commands
    for key, example in predicateExamples.GetAll() {
        example.Add("b", new Sequence([ new ResetGui(), predicateExamples ]).SetDescription("← Go back to examples"))
        predicateExamples.Add(key, WithHelpOpened(example))
    }



    ; ====== 4. WRAPPERS ======
    
    ; Wrappers add some functionality.
    ; We already used `WithHelpOpened` and `WithEnvironment`.
    ; It was said that they return the same command, but it works slightly differently.
    ; They create `Sequence` internally with some commands,
    ; then wrap that sequence in a special object that passes all method calls to given command, except for `Run`.
    ; This allows to pass `SetDescription` call directly to given object, omitting `Sequence.SetDescription`.
    ; `Run` call goes to `Sequence`, which will eventually call `Run` on given object.


    commands.Add("rel", new Reload())
    commands.Add("?", new Help())

    contr := new Controller(new Environment(), new Gui())
    contr.SetRootCommand(commands)

    activeExample := "composing"                            ; only-for-demo
    return                                                  ; only-for-demo


#If (activeExample == "composing")                          ; only-for-demo
{                                                           ; only-for-demo
    +^/::
        contr.Execute()
        return
}                                                           ; only-for-demo

#Include %A_ScriptDir%\src\Gui\GuiEscapes.ahk
