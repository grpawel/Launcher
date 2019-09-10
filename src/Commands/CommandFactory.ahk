#Include %A_ScriptDir%\src\Commands\ImportCommands.ahk
; Small shortcut for creating commands. Allows to not use `new` keyword everywhere.
; Intended only to use within UserCommands.ahk file.
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
    __Call(commandName, args*) {
        command := new %commandName%(args*)
        return command
    }
}