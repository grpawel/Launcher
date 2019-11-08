; Add all commands from given file.
; Subscribes to changes in that file.
;
; If command with given key already existed in `comSet` it is replaced.
; When that new command is then deleted from file, old replaced command is not brought back until script is reloaded.
; 
; Commands filtered with `FilterCommands` are not updated after changes in file.
WithCommandsFromFile(comFile, comSet) {
    commandsValues := comFile.ReadCommandsValues()
    for key, values in commandsValues {
        comSet.AddCommand(key, CommandValues.ToCommandStatic(values))
    }
    comFile.SubscribeCommandCreated(Func("_WithCommandsFromFile_OnCommandCreated").Bind(comSet))
    comFile.SubscribeCommandDeleted(Func("_WithCommandsFromFile_OnCommandDeleted").Bind(comSet))
    return comSet
}

_WithCommandsFromFile_OnCommandCreated(comSet, values) {
    com := values.ToCommand()
    comSet.AddCommand(values.key, com)
}

_WithCommandsFromFile_OnCommandDeleted(comSet, values) {
    comSet.RemoveCommand(values.key)
}
