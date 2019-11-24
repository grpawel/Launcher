; Helper function for using command as event callback.
; Supplies given controller to command, because events do not pass the controller.
; Event payload is passed as `context.event.payload`.
CommandToCallback(command, controller) {
    return Func("_CommandToCallback_Internal").Bind(command, controller)
}

_CommandToCallback_Internal(command, controller, payload = "") {
    return controller.RunCommandWithoutEvents(command, { event: {payload: payload}})
}
