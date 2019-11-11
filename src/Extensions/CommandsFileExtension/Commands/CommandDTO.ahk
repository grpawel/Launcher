class CommandDTO {
    name :=
    key :=
    fields := []
    description :=
    tags := []

    ToCommandStatic(dto) {
        commandClass := dto.name
        com := new %commandClass%(dto.fields*)
        if (dto.description != "") {
            com.SetDescription(dto.description)
        }
        com.AddTags(dto.tags)
        return com
    }

    ToCommand() {
        return this.ToCommandStatic(this)
    }
}
