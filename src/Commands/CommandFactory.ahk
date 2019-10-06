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
        if (commandObj == "") {
            MsgBox % "Class ``" commandClassName "`` does not exist."
        }
        else if (commandObj.base.base.__Class != "Command") {
            MsgBox % "Class ``" commandClassName "`` does not extend ``Command`` class, but ``" commandObj.base.base.__Class "``."
        }
        return commandObj
    }
}