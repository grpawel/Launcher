; Return given value or call a function.
; Helper method for commands.
; In many commands user can give string or function returning string.
GetValue(objOrFunc, contr, context) {
    callResult := %objOrFunc%(contr, context)
    if (callResult != "") {
        return callResult
    } else {
        return objOrFunc
    }
}
