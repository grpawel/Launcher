; Add all commands from given file.
; Subscribes to changes in that file.
;
; If command with given key already existed in `comSet` it is replaced.
; When that new command is then deleted from file, old replaced command is not brought back until script is reloaded.
; 
; Commands filtered with `Filter` are not updated after changes in file.
; Example:
/*
file := new CommandsFile("commands.json")
comSet := new CommandSet()
comSet.IncludeCommandsFile(file)
*/
_CommandSet_IncludeCommandsFile(this, comFile) {
    commandDTOs := comFile.ReadCommandDTOs()
    for key, dto in commandDTOs {
        this.Add(key, CommandDTO.ToCommandStatic(dto))
    }
    comFile.SubscribeCommandCreated(Func("_CommandSet_OnCommandCreatedInFile").Bind(this))
    comFile.SubscribeCommandDeleted(Func("_CommandSet_OnCommandDeletedFromFile").Bind(this))
    return this
}

_CommandSet_OnCommandCreatedInFile(comSet, dto) {
    com := dto.ToCommand()
    comSet.Add(dto.key, com)
}

_CommandSet_OnCommandDeletedFromFile(comSet, dto) {
    comSet.Remove(dto.key)
}
