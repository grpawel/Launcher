; Sample file with commands.
; Copy it and fill with your commands.
; See examples in Examples folder.
CreateCommands() {
    commands := new CommandSet().SetDescription("¯\_(ツ)_/̄")

    commands.AddCommand("goo", new Open("https://google.com").SetDescription("Google"))
    commands.AddCommand("ama", new Open("https://amazon.com"))
    commands.AddCommand("calc", new Open("calc"))
    commands.AddCommand("hosts", new Open("C:\Windows\system32\drivers\etc\hosts").SetDescription("hosts file"))
    commands.AddCommand("d ", new Search("https://duckduckgo.com?q=REPLACEME").SetDescription("Search in DuckDuckGo"))

    for letter in RangeAscii("C", "F") {
        commands.AddCommand(letter "/", new Open(letter ":\"))
    }

    commands.AddCommand("?", new Help(commands))
    commands.AddCommand("rel", new Reload())

    return WithHelpOpened(commands)
}
