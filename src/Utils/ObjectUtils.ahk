MergeArrays(arrays*) {
    result := {}
    for arrayIndex, array in arrays 
        for key, value in array
            result[key] := value
    return result
}

AddAll(target, arrays*) {
    for arrayIndex, array in arrays 
        for key, value in array
            target[key] := value
    return target
}

; Flip object keys and values.
; Example:
; obj := { "a": "AA", "b": "BB" }
; Flip(obj) == { "AA": "a", "BB": "b" }
Flip(object) {
    flipped := {}
    for key, value in object {
        flipped[value] := key
    }
    return flipped
}

ToString(obj) {
    string := ""
    _ToString_Recursive(obj, "", string)
    return string
}

_ToString_Recursive(obj, prefix, ByRef string) {
    if (IsObject(obj)) {
        for key, value in obj {
            _ToString_Recursive(value, prefix "." key, string)
        }
    } else {
        if (prefix != "") {
            string .= prefix " = " obj "`n"
        } else {
            string .= obj "`n"
        }
    }
}

Debug(objs*) {
    string := ""
    for i, obj in objs {
        string .= ToMultilineString(obj) "`n"
    }
    MsgBox, %string%
}

ToCompactString(obj) {
    if (IsObject(obj)) {
        if (IsArrayWithoutGapsAndStringKeys(obj)) {
            string := "["
            valueStrings := []
            for key, value in obj {
                valueStrings.Push(ToCompactString(obj[key]))
            }
            string .= Join(valueStrings, ", ")
            string .= "]"
        } else {
            string := "{"
            valueStrings := []
            for key, value in obj {
                valueStrings.Push(key ": " ToCompactString(obj[key]))
            }
            string .= Join(valueStrings, ", ")
            string .= "}"
        }
        return string
    } else {
        return """" obj """"
    }
}

ToMultilineString(obj, indent=1) {
    if (IsObject(obj)) {
        spaces := RepeatString(" ", indent)
        if (IsArrayWithoutGapsAndStringKeys(obj)) {
            string := "["
            for key, value in obj {
                nested := ToMultilineString(value, indent)
                string .= "`n" spaces StrReplace(nested, "`n", "`n" spaces)
            }
            if (string != "[") {
                string .= "`n]"
            } else {
                string .= "]"
            }
            return string
        } else {
            string := "{" 
            for key, value in obj {
                nested := ToMultilineString(value, indent)
                string .= "`n" spaces key ": " StrReplace(nested, "`n", "`n" spaces)
            }
            if (string != "{") {
                string .= "`n}"
            } else {
                string .= "}"
            }
            return string
        }
    } else {
        return """" obj """"
    }
}

; Returns array index if `array` contains `searched`, 0 if not.
; Array should contain only numerical keys >= 1.
ArrayContains(array, searched) {
    for index, value in array {
        if (value == searched)
            return index
    }
    return 0
}

IsArray(obj) {
    return !!obj.MaxIndex()
}

IsArrayWithoutGapsAndStringKeys(obj) {
    i := 1
    for key, v in obj {
        if (key != i) {
            return false
        }
        i += 1
    }
    return true
}

; Returns true if arrays have at least one matching value.
Intersect(array1, array2) {
    for index, value in array1 {
        if (ArrayContains(array2, value)) {
            return true
        }
    }
    return false
}

EnsureArray(ByRef var) {
    if (!IsArray(var)) {
        var := [var]
    }
}

; Add key to object if it does not exist.
; Key is initialized to `initialValue`.
EnsureHasKey(obj, key, initialValue = "") {
    if (!obj.HasKey(key)) {
        obj[key] := initialValue
    }
}

; Workaround for not being able to use `{}` as default parameter
EnsureIsObject(ByRef obj) {
    if (obj == "") {
        obj := {}
    }
    return obj
}

AnyKey(object) {
    for key, value in object {
        return key
    }
}

HasAnyKey(object) {
    for key, value in object {
        return true
    }
    return false
}

Keys(object) {
    keys := []
    for key, o in object {
        keys.Push(key)
    }
    return keys
}
