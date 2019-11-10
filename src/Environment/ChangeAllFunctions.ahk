; Change all existing functions to `functionName`.
; For use with `ChangeEnvironment` or `WithEnvironment`.
; Example:
/*
; All commands using some function from env will have its argument copied to clipboard
new ChangeEnvironment(ChangeAllFunctions("CopyToClipboard"))


*/
ChangeAllFunctions(functionName) {
    envFunction := Func(functionName)
    return Func("_ChangeAllFunctions").Bind(envFunction)
}

_ChangeAllFunctions(envFunction, contr, context) {
    functionNames := contr.GetEnvironment().GetFunctionNames()
    change := {}
    for i, name in functionNames {
        change[name] := envFunction
    }
    return { functions: change }
}
