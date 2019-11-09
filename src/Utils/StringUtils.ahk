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
