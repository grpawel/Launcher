#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk

; All functions in this file work in similar way.
; They return another function (filter) that checks its argument in some way and returns boolean.
; Usable for filtering, for example to get only some commands from `CommandSet` objects.
; Example with `IsClass` filter: 
; objA := new ClassA();
; objC := new ClassC();
; filter := IsClass(["ClassA", "ClassB"])
; %filter%(objA) ; == true
; %filter%(objC) ; == false

; Filter by class name
; Returns true if its argument has one of specified classes.
IsClass(classes) {
    if (!IsArray(classes)) {
        classes := [classes]
    }
    return Func("_IsClassFilter").Bind(classes)
}

_IsClassFilter(classes, object) {
    return ArrayContains(classes, object.__Class)
}

IsCommand(commandNames) {
    if (!IsArray(commandNames)) {
        commandNames := [commandNames]
    }
    return Func("_IsCommandFilter").Bind(commandNames)
}

_IsCommandFilter(commandNames, com) {
    commandName := com.GetCommandName()
    return ArrayContains(commandNames, commandName)
}

; Filter by tags
; Returns true if its argument has `GetTags` method returning array value containing any of specified tags.
HasTag(tags) {
    if (!IsArray(tags)) {
        tags := [tags]
    }
    return Func("_HasTagFilter").Bind(tags)
}

_HasTagFilter(tags, object) {
    objectTags := object.GetTags()
    return IsArray(objectTags)
        && Intersect(tags, objectTags)
}

; Join filters using OR function.
; Returns true if any of the filters matches.
OrFunc(filters*) {
    return Func("_Or_Filter").Bind(filters)
}

_Or_Filter(filters, object) {
    for _, filter in filters {
        result := %filter%(object)
        if (result) {
            return result
        }
    }
    return false
}

_GenericFilterDecorator(arrayArgument, functionName) {
    if (!IsArray(arrayArgument)) {
        arrayArgument := [arrayArgument]
    }
    return Func(functionName).Bind(arrayArgument)
}