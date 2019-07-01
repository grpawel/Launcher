CreateCommands() {
    global Commands
    Commands := { topLevel: { title: "Enter anything"
                            , commands: { google: ["open", "http://google.com"]
                                        , chr: ["open", "chrome"]
                                        , fire: ["open", "firex"]
                                        , ahk: ["enter", "ahk"]
                                        , rel: ["Reload", {}]}}
                , ahk:  { title: "ahk"
                        , commands: { vsc: ["open", "vscode ."]
                                    , dir: ["open", "explorer ."]}}}
    return
}