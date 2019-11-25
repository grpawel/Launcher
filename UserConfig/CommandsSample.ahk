; Sample file with commands.
; Copy it and fill with your commands.
; See also examples in Examples folder with more features.
CreateCommands() {
    commands := new CommandSet().SetDescription("¯\_(ツ)_/̄")

    ; Simple commands
    commands.Add("goo", new Web("https://google.com").SetDescription("Google"))
    commands.Add("g ", new Search("https://google.com/search?q=REPLACEME"))
    commands.Add("d ", new Search("https://duckduckgo.com?q=REPLACEME").SetDescription("Search in DuckDuckGo"))
    commands.Add("b ", new Search("https://bing.com/search?q=REPLACEME"))
    commands.Add("ama", new Web("https://amazon.com"))
    commands.Add("face", new Web("https://facebook.com"))
    commands.Add("red", new Web("https://reddit.com").AddTag("entertainment"))
    commands.Add("/", new Search("https://reddit.com/r/REPLACEME").SetDescription("Subreddit").AddTag("entertainment"))
    commands.Add("yout", new Web("https://youtube.com").SetDescription("YouTube").AddTag("entertainment"))
    commands.Add("yt", new Search("https://duckduckgo.com/?q=!ducky+youtube+REPLACEME")
                            .SetDescription("Open first YouTube result from DuckDuckGo")
                            .AddTag("entertainment"))
    commands.Add("calc", new Open("calc"))
    commands.Add("pai", new Open("paint"))
    commands.Add("note", new Open("notepad"))
    commands.Add("hosts", new File("C:\Windows\system32\drivers\etc\hosts").SetDescription("hosts file"))
    commands.Add("text", new Copy("some text to copy").SetDescription("Copy some text to clipboard"))
    commands.Add("down", new Folder("shell:::{374DE290-123F-4565-9164-39C4925E467B}").SetDescription("Downloads folder"))
    commands.Add("@", new TypeText("name@domain.com"))
    commands.Add("own", new FunctionToCommand(Func("SomeFunction")).SetDescription("Run own function"))

    for letter in RangeAscii("C", "F") {
        commands.Add(letter "/", new Open(letter ":\"))
    }

    ; More complicated commands

    ; Show next input, but instead of opening argument will be copied to clipboard:
    ; run "goo" -> "https://google.com" is opened
    ; run "copy" -> run "goo" -> "https://google.com" is in clipboard
    commands.Add("copy", WithEnvironment(ChangeAllFunctions(Func("ToClipboardCopier"))
                                        , WithHelp(new CommandSet()).Observe(commands)
                                        .SetDescription("Copy next command to clipboard")))

    ; Show next input, but list only `Web` and `Search` commands
    ; and open them using Firefox
    ; run "ff" -> run "d " -> type "something" -> https://duckduckgo.com/?q=something is opened in Firefox
    commands.Add("ff", WithEnvironment({ settings: { browser: "C:\Program Files\Mozilla Firefox\firefox.exe"}}
                                      , WithHelp(new CommandSet())
                                         .Observe(commands, new Pipeline().Filter(IsCommand(["Web", "Search"]))) )
                                      .SetDescription("Open website in Firefox"))

    ; Show next input, but list only `Web` and `Search` commands or those having "Web" tag
    ; and open them using Chrome incognito mode
    ; run "inc" -> run "d " -> type "something" -> https://duckduckgo.com/?q=something is opened in Incognito mode
    commands.Add("inc", WithEnvironment({ settings: { browser: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe -incognito"}}
                                      , WithHelp(new CommandSet())
                                         .Observe(commands, new Pipeline()
                                                .Filter(OrFunc(IsCommand(["Web", "Search"])
                                                              , HasTag("Web")))) )
                                      .SetDescription("Open website in Incognito mode"))

    ; Show input for Google search and type "AutoHotkey " into it
    ; run "ahk" -> type "gui" -> "AutoHotkey gui" is searched in google
    commands.Add("ahk", new Sequence([ new Search("https://google.com/?q=REPLACEME")
                                     , new TypeText("AutoHotkey ", { when: "immediate" }) ])
                            .SetDescription("Search for Autohotkey")
                            .AddTags(["Web"]))

    ; Show input and share it between three searches - will open 3 websites
    ; run "search" -> type "something" -> three websites open
    commands.Add("search", new ShareControls([ new ShowMessage("Use multiple search engines")
                                             , new Search("https://google.com/search?q=REPLACEME")
                                             , new Search("https://duckduckgo.com/?q=REPLACEME")
                                             , new Search("https://bing.com/search?q=REPLACEME")]
                                             , { noDestroyCommands: 1 })
                                .SetDescription("Search multiple websites")
                                .AddTags(["Web"]))

    ; Block all commands having "entertainment" tag
    ; run "block" -> run "yout" -> does not work
    blocker := new BlockCommands(HasTag("entertainment"), { fallbackReason: "no entertainment for you" })
    commands.Add("block", blocker.SetDescription("Block entertainment commands"))
    commands.Add("unblock", new RevertCommand(blocker))

    commands.Add("?", new Help())
    commands.Add("rel", new Reload())

    return WithHelp(commands)
}

SomeFunction() {
    var := 2+2*2
    Clipboard := "var is " var
}