FolderCommands(comSet, path, openDescription = "Folder", copyDescription = "Copy folder path") {
    comSet.Add("fo", new Folder(path).SetDescription(openDescription))
    comSet.Add("pa", new Copy(path).SetDescription(copyDescription))
}
