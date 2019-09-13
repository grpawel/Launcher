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


; Adds or replaces all keys from `overrides` to `base`. Base object is modified and returned.
; Example: ObjectDeepAssign( { a: 1, b: {c: 3} }
;                          , { a: 2, b: {d: 4} } )
;                         == { a: 2, b: {c: 3, d: 4} }
ObjectDeepAssign(base, overrides) {
    for key, value in overrides {
        if not base.HasKey(key) {
            ; key does not exist => assign whatever there is
            base[key] := value
        } else if not IsObject(value) {
            ; value is a primitive => assign it
            base[key] := value
        } else if base[key].base <> value.base {
            ; different class => assign whole object, not looking inside
            base[key] := value
        } else {
            ; same class => recurse inside
            base[key] := ObjectDeepAssign(base[key], overrides[key])
        }
    }
    return base
}


; Clones object, works for circular references
; https://autohotkey.com/board/topic/85201-array-deep-copy-treeview-viewer-and-more/
; https://rosettacode.org/wiki/Deepcopy#AutoHotkey
ObjectDeepCopy(Array, Objs=0)
{
    if !Objs
        Objs := {}
    Obj := Array.Clone()
    Objs[&Array] := Obj ; Save this new array
    For Key, Val in Obj
        if (IsObject(Val)) ; If it is a subarray
            Obj[Key] := Objs[&Val] ; If we already know of a refrence to this array
            ? Objs[&Val] ; Then point it to the new array
            : ObjectDeepCopy(Val,Objs) ; Otherwise, clone this sub-array
    return Obj
}

EnsureArray(ByRef var) {
    if (!IsArray(var)) {
        var := [var]
    }
}
