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

; from https://www.autohotkey.com/boards/viewtopic.php?p=255613#p255613
Obj2String(Obj,FullPath:=1,BottomBlank:=0){
	static String,Blank
	if(FullPath=1)
		String:=FullPath:=Blank:=""
	if(IsObject(Obj)){
		for a,b in Obj{
			if(IsObject(b))
				Obj2String(b,FullPath "." a,BottomBlank)
			else{
				if(BottomBlank=0)
					String.=FullPath "." a " = " b "`n"
				else if(b!="")
					String.=FullPath "." a " = " b "`n"
				else
					Blank.=FullPath "." a " =`n"
			}
	}}
	return String Blank
}

Debug(obj, title = "") {
    string := Obj2String(obj)
    MsgBox, %title% `n %string%
}

ArrayContains(array, searched) {
    for index, value in array {
        if (value == searched)
            return true
    }
    return false
}

IsArray(obj) {
    return !!obj.MaxIndex()
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
