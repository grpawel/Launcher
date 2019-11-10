; Returns function that returns some setting value when called with controller.
; Example usage:
/*
new ShowMessage(GetEnvironmentSetting("browser")).SetDescription("Show current browser")
*/
GetEnvironmentSetting(setting) {
    return Func("GetEnvironmentSettingFunction").Bind(setting)
}

GetEnvironmentSettingFunction(setting, contr, context) {
    return contr.GetEnvironment().GetSetting(setting)
}

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
