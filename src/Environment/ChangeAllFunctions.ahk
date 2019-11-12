; Change all existing functions to `functionObj`.
; `functionObj` is function object.
; For use with `ChangeEnvironment` or `WithEnvironment`.
; Example:
/*
; All commands using some function from env will have its argument copied to clipboard
new ChangeEnvironment(ChangeAllFunctions(Func("ToClipboardCopier")))
*/
ChangeAllFunctions(functionObj) {
    return Func("_ChangeAllFunctions").Bind(functionObj)
}

_ChangeAllFunctions(functionObj, contr, context) {
    functionNames := contr.GetEnvironment().GetFunctionNames()
    change := {}
    for i, name in functionNames {
        change[name] := functionObj
    }
    return { functions: change }
}
