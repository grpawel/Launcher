#Include %A_ScriptDir%\src\Utils\ObjectUtils.ahk

; All functions in this file work in similar way.
; They return another function (predicate) that checks its argument in some way and returns boolean.
; Usable for filtering, blocking commands etc.
; Example:
/*
objA := new ClassA()
objC := new ClassC()
pred := IsClass(["ClassA", "ClassB"])
pred.Call(objA) ; == true
pred.Call(objC) ; == false
*/
/*
comSet2.AddCommands(comSet1.FilterCommands(HasTag(["web"])))
*/
/*
new BlockCommands(HasTag(["entertainment"], )
*/
; Check class name
; Returns true if its argument has one of specified classes.
; Does not check classes higher in hierarchy.
IsClass(classes) {
    EnsureArray(classes)
    return Func("IsClassPredicate").Bind(classes)
}

IsClassPredicate(classes, object) {
    return ArrayContains(classes, object.__Class)
}

; Check command name
IsCommand(commandNames) {
    EnsureArray(commandNames)
    return Func("IsCommandPredicate").Bind(commandNames)
}

IsCommandPredicate(commandNames, com) {
    commandName := com.GetCommandName()
    return ArrayContains(commandNames, commandName)
}

; Check tags
; Returns true if `object.GetTags()` contains any of the specified tags.
HasTag(tags) {
    EnsureArray(tags)
    return Func("HasTagPredicate").Bind(tags)
}

HasTagPredicate(tags, object) {
    objectTags := object.GetTags()
    return IsArray(objectTags)
        && Intersect(tags, objectTags)
}

; Join predicates using OR function.
; Returns true if any of the predicates returns true.
OrFunc(predicates*) {
    return Func("OrFuncPredicate").Bind(predicates)
}

OrFuncPredicate(predicates, object) {
    for _, predicate in predicates {
        result := %predicate%(object)
        if (result) {
            return result
        }
    }
    return false
}

; Returns true if all of the given functions returns true.
AndFunc(predicates*) {
    return Func("AndFuncPredicate").Bind(predicates)
}

AndFuncPredicate(predicates, object) {
    for _, predicate in predicates {
        if (%predicate%(object) == false) {
            return false
        }
    }
    return true
}

AlwaysTrue() {
    return Func("AlwaysTruePredicate")
}

AlwaysTruePredicate(params*) {
    return true
}
