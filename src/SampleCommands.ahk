CreateCommands() {
    global Commands
    Commands := { topLevel: { title: "Enter anything"
                            , commands: { google: ["open", "http://google.com"]
                                        , chr: ["open", "chrome"]
                                        , fire: ["open", "firefox"]
                                        , goto1: ["enter", "test1"]
                                        , goto2: ["enter", "test2"]
                                        , rel: ["Reload", {}]}}
                , test1:    { title: "test1"
                            , commands: { goto0: ["enter", "topLevel"]
                                        , goto1: ["enter", "test1"]
                                        , goto2: ["enter", "test2"]}}
                , test2:    { commands: { goto0: ["enter", "topLevel"]
                                        , goto1: ["enter", "test1"]
                                        , goto2: ["enter", "test2"]}}
                , dummycommand: {}}
    return
}