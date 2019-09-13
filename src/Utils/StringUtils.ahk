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