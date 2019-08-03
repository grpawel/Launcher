CreateCommands() {
    topLevel := new CommandSet()
    
    topLevel.title := "Enter anything"
    searches := { "g ": new Search("http://google.com/search?q=REPLACEME", "Search in Google")
                , "d " : new Search("https://duckduckgo.com/?q=REPLACEME", "Search in DuckDuckGo")
                , "i ": new Search("""firefox"" ""-private-window"" ""https://duckduckgo.com/?q=REPLACEME""", "Search incognito") }
    websites := { goo: new Open("http://google.com")
                , ama: new Open("http://amazon.com") }

    programs := { fir: new Open("firefox")
                , chr: new Open("chrome")
                , calc: new Open("calc").SetDescription("Calculator")
                , inco: new Open("""firefox"" ""-private-window""")
                        .SetDescription("Private firefox window") }
    
    misc :=     { rel: new Reload()
                , "?": new Help()
                , help: new Help() }

    drives :=  { }
    for i in range(Asc("C"), Asc("M") + 1) {
        letter := Chr(i)
        drives[letter "\"] := new Open(letter ":\")
    }
    
    topLevel.commands := MergeArrays(searches, websites, programs, misc, drives)

    return topLevel
}