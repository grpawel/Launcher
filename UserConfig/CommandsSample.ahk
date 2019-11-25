; Sample file with commands.
; Copy it and fill with your commands.
; See examples in Examples folder.
CreateCommands() {
    commands := new CommandSet().SetDescription("¯\_(ツ)_/̄")

    commands.Add("goo", new Open("https://google.com").SetDescription("Google"))
    commands.Add("ama", new Open("https://amazon.com"))
    commands.Add("calc", new Open("calc"))
    commands.Add("hosts", new Open("C:\Windows\system32\drivers\etc\hosts").SetDescription("hosts file"))
    commands.Add("d ", new Search("https://duckduckgo.com?q=REPLACEME").SetDescription("Search in DuckDuckGo"))

    for letter in RangeAscii("C", "F") {
        commands.Add(letter "/", new Open(letter ":\"))
    }

    commands.Add("?", new Help(commands))
    commands.Add("rel", new Reload())

    return WithHelp(commands)
}
