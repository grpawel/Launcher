#Include %A_ScriptDir%\src\Utils\Range.ahk

; Returns random string of given length containing printable non-space ASCII characters (from range 33-126).
RandomString(length) {
    ascii_begin := 33
    ascii_end := 126
    string := ""
    for i in range(length) {
        Random, letter, ascii_begin, ascii_end
        string .= Chr(letter)
    }
    return string
}

; Returns random string using only a-z characters.
RandomAzString(length) {
    ascii_begin := Asc("a")
    ascii_end := Asc("z")
    string := ""
    for i in range(length) {
        Random, letter, ascii_begin, ascii_end
        string .= Chr(letter)
    }
    return string
}

Join(stringArray, separator) {
    joined := ""
    isFirstElement := true
    for i, element in stringArray {
        if (isFirstElement) {
            joined := element
            isFirstElement := false
        } else {
            joined := joined separator element
        }
    }
    return joined
}

Wrap(obj, prefix, postfix) {
    if (isArray(obj)) {
        return WrapArray(obj, prefix, postfix)
    }
    else {
        return prefix obj postfix
    }
}

WrapArray(stringArray, prefix, postfix) {
    wrapped := []
    for i, string in stringArray {
        wrapped[i] := prefix string postfix
    }
    return wrapped
}

StartsWith(haystack, needle) {
    return InStr(haystack, needle) == 1
}

RepeatString(string, times) {
    repeated := ""
    for i in range(times) {
        repeated .= string
    }
    return repeated
}

CountOccurences(string, substring) {
    StrReplace(string, substring, substring, occurences)
    return occurences
}

; Ensure that `var` is in [min, max] range
EnsureBetween(var, min, max) {
    if (var < min) {
        var := min
    } else if (var > max) {
        var := max
    }
    return var
}
