#Include %A_ScriptDir%\src\Executables\CommandSet\ImportCommands.ahk
class CommandFactory {
    ; Small shortcut for creating commands. Allows to not use `new` keyword everywhere.
    ; This can visually declutter script.
    ; Works only with commands extending `Command` class.
    ; Example:
    ; _ := new CommandFactory()
    ; ; creating command with `CommandFactory`:
    ; _.Open("...")
    ; ; creating command usual way:
    ; new Open("...")
    __Call(commandName, args*) {
        command := new %commandName%(args*)
        if (command == "" || command.base.base.__Class != "Command") {
            throw, "Command" %commandName% "does not exist"
        }
        return command
    }
}