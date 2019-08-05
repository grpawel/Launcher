#Include %A_ScriptDir%\src\Executables\CommandSet\Operations\Filters.ahk
#Include %A_ScriptDir%\src\Environment\ImportOpeners.ahk

CreateCommands() {
    browsers := { firefox: new RunOpener("""firefox""")
                , chrome: new RunOpener("""chrome""")
                , firefoxPrivate: new RunOpener("""firefox"" ""-private-window""")
                , default: new RunOpener("") }

    openers :=  { default: new RunOpener("explorer")
                , copy: new CopyToClipboardOpener() }
                    
    topLevel := new CommandSet()
    incognito := new CommandSet()
    clip := new CommandSet()
    
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
                , inco: new Switch(incognito)
                , clip: new Switch(clip) }

    folders :=  { user: new Folder("%USERPROFILE%")
                , doc: new Folder("%USERPROFILE%\Documents") }
    files :=    { hosts: new File("%SystemRoot%\System32\drivers\etc\hosts") }
    
    drives :=  { }
    for i in range(Asc("C"), Asc("M") + 1) {
        letter := Chr(i)
        drives[letter "\"] := new Folder(letter ":\")
    }
    
    topLevel.commands := MergeArrays(searches, websites, programs, misc, drives, folders, files)

    incognito.title := "Incognito mode"
    incognito.commands := topLevel.FilterCommands(HasTag(["web", "technical"])).commands
    incognito.environmentOverride := { browser: browsers.FirefoxPrivate }

    clip.title := "Copy to clipboard"
    clip.commands := topLevel.FilterCommands(HasTag(["hasPath"])).commands
    clip.environmentOverride := { browser: openers.copy, fileOpener: openers.copy, folderOpener: openers.copy, defaultOpener: openers.copy }

    return topLevel
}