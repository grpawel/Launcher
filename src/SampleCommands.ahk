#Include %A_ScriptDir%\src\Executables\CommandSet\Operations\Filters.ahk
CreateCommands() {
    browsers := { firefox: new Opener("""firefox""")
                , chrome: new Opener("""chrome""")
                , firefoxPrivate: new Opener("""firefox"" ""-private-window""")
                , default: new Opener("") }
                    
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
                , setfire: new ChangeEnvironment({ browser: browsers.firefox }).SetDescription("Change browser to Firefox")
                , setchr: new ChangeEnvironment({ browser: browsers.chrome }).SetDescription("Change browser to Chrome") }
    
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
    incognito.commands := topLevel.FilterCommands(HasTag(["web", "technical"])).commands
    incognito.environmentOverride := { browser: browsers.FirefoxPrivate }

    return topLevel
}