; Sample file with commands.
; Copy it and fill with your commands.
; See examples in Examples folder.
CreateCommands() {
    commands := new CommandSet().SetDescription("¯\_(ツ)_/̄")

    ; Simple commands
    commands.Add("goo", new Web("https://google.com").SetDescription("Google"))
    commands.Add("ama", new Web("https://amazon.com"))
    commands.Add("calc", new Open("calc"))
    commands.Add("hosts", new File("C:\Windows\system32\drivers\etc\hosts").SetDescription("hosts file"))
    commands.Add("d ", new Search("https://duckduckgo.com?q=REPLACEME").SetDescription("Search in DuckDuckGo"))
    commands.Add("email", new TypeText("name@domain.com"))
    commands.Add("text", new Copy("some text to copy").SetDescription("Copy some text to clipboard"))

    for letter in RangeAscii("C", "F") {
        commands.Add(letter "/", new Open(letter ":\"))
    }

    ; More complicated commands

    ; Show next input, but instead of opening command will be copied to clipboard:
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

    commands.Add("?", new Help())
    commands.Add("rel", new Reload())

    return WithHelp(commands)
}
