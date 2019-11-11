; Add all commands from given file.
; Subscribes to changes in that file.
;
; If command with given key already existed in `comSet` it is replaced.
; When that new command is then deleted from file, old replaced command is not brought back until script is reloaded.
; 
; Commands filtered with `FilterCommands` are not updated after changes in file.
; Example:
/*
file := new CommandsFile("commands.json")
comSet := new CommandSet()
comSet.IncludeCommandsFile(file)
*/
_CommandSet_IncludeCommandsFile(this, comFile) {
    commandsValues := comFile.ReadCommandsValues()
    for key, values in commandsValues {
        this.AddCommand(key, CommandValues.ToCommandStatic(values))
    }
    comFile.SubscribeCommandCreated(Func("_CommandSet_OnCommandCreatedInFile").Bind(this))
    comFile.SubscribeCommandDeleted(Func("_CommandSet_OnCommandDeletedFromFile").Bind(this))
    return this
}

_CommandSet_OnCommandCreatedInFile(comSet, values) {
    com := values.ToCommand()
    comSet.AddCommand(values.key, com)
}

_CommandSet_OnCommandDeletedFromFile(comSet, values) {
    comSet.RemoveCommand(values.key)
}
