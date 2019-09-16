#Include %A_ScriptDir%\src\Commands\Command.ahk

; Change environment and run command
; Small helper function.
; Uses description and tags from given CommandSet.
WithEnvironment(environmentChange, wrapped) {
    return new Sequence([new ChangeEnvironment(environmentChange, "untilGuiClosed"), wrapped])
        .SetDescription(wrapped.GetDescription())
        .AddTags(wrapped.tags)
}