class CommandValues {
    name :=
    key :=
    fields := []
    description :=
    tags := []

    ToCommandStatic(values) {
        commandClass := values.name
        com := new %commandClass%(values.fields*)
        if (values.description != "") {
            com.SetDescription(values.description)
        }
        com.AddTags(values.tags)
        return com
    }

    ToCommand() {
        return this.ToCommandStatic(this)
    }
}
