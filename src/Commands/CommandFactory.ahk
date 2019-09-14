#Include %A_ScriptDir%\src\Commands\ImportCommands.ahk
; Small shortcut for creating commands. Allows to not use `new` keyword everywhere.
; Works only with commands extending `Command` class.
; 
; Example using CommandFactory:
; _ := new CommandFactory()
; _.Open("something")
; _.Folder("somepath")
;
; Example without CommandFactory (`new` everywhere):
; new Open("something")
; new Folder("somepath")
class CommandFactory {
    __Call(commandClassName, args*) {
        commandObj := new %commandClassName%(args*)
        if (commandObj == "" || commandObj.base.base.__Class != "Command") {
            throw, "Command """ commandClassName """ does not exist"
        }
        return commandObj
    }
}