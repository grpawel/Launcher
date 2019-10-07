; Helper function for supplying controller to commands,
; when subscribing to events not providing the controller.
; Rest of arguments are passed unchanged to command after the controller.
; Problem:
; command := new SomeCommand(...)
; SubscribeSomeEvent(command) ; wrong - SomeEvent does not send the controller that the command needs
; Solution:
; command := new SomeCommand(...)
; controller ; supposing we have it
; SubscribeSomeEvent(BindControllerToCommand(command, controller)) ; ok - the command will receive the controller
BindControllerToCommand(command, controller) {
    return Func("_BindControllerToCommand_Internal").Bind(command, controller)
}

_BindControllerToCommand_Internal(command, controller, args*) {
    return command.Run(controller, args*)
}
