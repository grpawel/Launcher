﻿#Include %A_ScriptDir%\src\Commands\Filters.ahk
#Include %A_ScriptDir%\src\Environment\ImportOpeners.ahk

CreateCommands() {
    browsers := { firefox: """firefox"""
                , chrome: """chrome"""
                , firefoxPrivate: """firefox"" ""-private-window""" }
    _ := new CommandFactory()

    topLevel := _.CommandSet()
    incognito := _.CommandSet()
    clip := _.CommandSet()
    
    topLevel.SetDescription("Enter anything")
    searches := { "g ": _.Search("http://google.com/search?q=REPLACEME").SetDescription("Search in Google")
                , "d " : _.Search("https://duckduckgo.com/?q=REPLACEME").SetDescription("Search in DuckDuckGo")
                , "i ": _.Search("""firefox"" ""-private-window"" ""https://duckduckgo.com/?q=REPLACEME""").SetDescription("Search incognito") }

    websites := { goo: _.Web("http://google.com")
                , ama: _.Web("http://amazon.com") }

    programs := { fir: _.Open("firefox")
                , chr: _.Open("chrome")
                , calc: _.Open("calc").SetDescription("Calculator")
                , priv: _.Open("""firefox"" ""-private-window""")
                        .SetDescription("Private firefox window")
                , setfire: _.ChangeEnvironment({ browser: browsers.firefox }).SetDescription("Change browser to Firefox")
                , setchr: _.ChangeEnvironment({ browser: browsers.chrome }).SetDescription("Change browser to Chrome") }
    
    misc :=     { rel: _.Reload()
                , "?": _.Help()
                , help: _.Help()
                , inco: _.Sequence([ _.ChangeEnvironment({browser: browsers.FirefoxPrivate}, "untilGuiClosed")
                                    , incognito ])
                , clip: _.Sequence([ _.ChangeEnvironment({ Open: new CopyToClipboardOpener() }, "untilGuiClosed")
                                    , Helpy(clip) ]) }

    folders :=  { user: _.Folder("%USERPROFILE%")
                , doc: _.Folder("%USERPROFILE%\Documents") }
    files :=    { hosts: _.File("%SystemRoot%\System32\drivers\etc\hosts") }
    
    drives :=  { }
    for i in range(Asc("C"), Asc("M") + 1) {
        letter := Chr(i)
        drives[letter "\"] := _.Folder(letter ":\")
    }
    
    topLevel.commands := MergeArrays(searches, websites, programs, misc, drives, folders, files)

    incognito.SetDescription("Incognito mode")
    incognito.commands := topLevel.FilterCommands(HasTag(["web", "technical"])).commands

    clip.SetDescription("Copy to clipboard")
    clip.commands := topLevel.FilterCommands(HasTag(["hasPath", "technical"])).commands

    return topLevel
}