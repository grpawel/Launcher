CreateCommands() {
    topLevel := new CommandSet()
    test1 := new CommandSet()
    test2 := new CommandSet()
    
    topLevel.title := "Enter anything"
    topLevel.commands :=    { google: ["open", "http://google.com"]
                            , "g ": ["search", "http://google.com/search?q=REPLACEME"]
                            , chr: ["open", "chrome"]
                            , fire: ["open", "firefox"]
                            , goto0: ["enter", topLevel]
                            , goto1: ["enter", test1]
                            , goto2: ["enter", test2]
                            , rel: ["Reload", ""]}
    
    test1.title := "test1"
    test1.commands :=   { goto0: ["enter", topLevel]
                        , goto1: ["enter", test1]
                        , goto2: ["enter", test2]}
    test2.title := "test2"    
    test2.commands :=   { goto0: ["enter", topLevel]
                        , goto1: ["enter", test1]
                        , goto2: ["enter", test2]}

    return topLevel
}