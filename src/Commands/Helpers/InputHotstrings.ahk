; Create `CommandSet` with commands that delete existing input and type expansion.
; Example
/*
searchHotstrings := InputHotstrings({ ahk": "AutoHotkey "
                                    , "w10": "Windows 10 " })
new ShareControls([ new Search("google.com/search?q=REPLACEME").SetDescription("Search Google")
                  , searchHotstrings ]
                 , { allowDisabling: false }).SetDescription("Search with hotstrings")
*/
InputHotstrings(hotstrings) {
    comSet := new CommandSet()
    for abbrev, expanded in hotstrings {
        toType := RepeatString("{Backspace}", StrLen(abbrev)) expanded 
        comSet.AddCommand(abbrev, new TypeText(toType, { when: "immediate" }))
    }
    return comSet
}
