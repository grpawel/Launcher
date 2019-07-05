CreateCommands(actions) {
    a := actions
    topLevel := new CommandSet()
    test1 := new CommandSet()
    test2 := new CommandSet()
    
    topLevel.title := "Enter anything"
    topLevel.commands :=    { google: [a.open, "http://google.com"]
                            , "g ": [a.search, new WebSearch("http://google.com/search?q=REPLACEME", "Search in Google")]
                            , chr: [a.open, "chrome"]
                            , fire: [a.open, "firefox"]
                            , goto0: [a.enter, topLevel]
                            , goto1: [a.enter, test1]
                            , goto2: [a.enter, test2]
                            , rel: [a.reload, ""]}
    
    test1.title := "test1"
    test1.commands :=   { goto0: [a.enter, topLevel]
                        , goto1: [a.enter, test1]
                        , goto2: [a.enter, test2]}
    test2.title := "test2"    
    test2.commands :=   { goto0: [a.enter, topLevel]
                        , goto1: [a.enter, test1]
                        , goto2: [a.enter, test2]}

    for i in range(Asc("a"), Asc("m") + 1) {
        driveLetter := Chr(i)
        topLevel.commands[driveLetter "/"] := new Open(driveLetter ":\")
    }

    return topLevel
}