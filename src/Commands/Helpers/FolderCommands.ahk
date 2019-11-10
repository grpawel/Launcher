FolderCommands(comSet, path, openDescription = "Folder", copyDescription = "Copy folder path") {
    comSet.AddCommand("fo", new Folder(path).SetDescription(openDescription))
    comSet.AddCommand("pa", new Copy(path).SetDescription(copyDescription))
}
