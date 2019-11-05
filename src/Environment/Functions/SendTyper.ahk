SendTyperChange() {
    function := Func("SendTyper")
    return  { functions: { type: function
                         , open: function
                         , copy: function } }
}

SendTyper(env, setting, string) {
    Send, %string%
}
