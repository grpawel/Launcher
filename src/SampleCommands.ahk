CreateCommands() {
    topLevel := new CommandSet()
    incognito := new CommandSet()
    
    topLevel.title := "Enter anything"
    searches := { "g ": new Search("http://google.com/search?q=REPLACEME", "Search in Google")
                , "d " : new Search("https://duckduckgo.com/?q=REPLACEME", "Search in DuckDuckGo")
                , "i ": new Search("""firefox"" ""-private-window"" ""https://duckduckgo.com/?q=REPLACEME""", "Search incognito") }

    websites := { goo: new Web("http://google.com")
                , ama: new Web("http://amazon.com") }

    programs := { fir: new Open("firefox")
                , chr: new Open("chrome")
                , calc: new Open("calc").SetDescription("Calculator")
                , inco: new Open("""firefox"" ""-private-window""")
                        .SetDescription("Private firefox window")
                , setfire: new ChangeBrowser("""firefox""").SetDescription("Change browser to Firefox")
                , setchr: new ChangeBrowser("""chrome""").SetDescription("Change browser to Chrome") }
    
    misc :=     { rel: new Reload()
                , "?": new Help()
                , help: new Help()
                , inco: new Switch(incognito) }

    drives :=  { }
    for i in range(Asc("C"), Asc("M") + 1) {
        letter := Chr(i)
        drives[letter "\"] := new Open(letter ":\")
    }
    
    topLevel.commands := MergeArrays(searches, websites, programs, misc, drives)

    incognito.title := "Incognito mode"
    incognito.commands := websites
    incognito.commandsBeforeRunning := [ new ChangeBrowser("""firefox"" ""-private-window""") ]
    incognito.commandsAfterRunning := [ new ChangeBrowser("""firefox""") ]
    Debug(incognito)

    return topLevel
}