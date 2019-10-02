SendTyper() {
    function := Func("_SendTyper")
    return  { "TypeText": function }
}

_SendTyper(env, string) {
    Send, %string%
}
