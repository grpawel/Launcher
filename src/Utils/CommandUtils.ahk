; Helper function for using command as event subsctiber.
; Supplies given controller to command, because events do not pass the controller.
; Event payload is passed as `context.event.payload`.
CommandAsSubscriber(command, controller) {
    return Func("_CommandAsSubscriber_Internal").Bind(command, controller)
}

_CommandAsSubscriber_Internal(command, controller, payload) {
    return controller.RunCommandWithoutEvents(command, { event: {payload: payload}})
}
