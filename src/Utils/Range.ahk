; https://www.autohotkey.com/boards/viewtopic.php?p=24002&sid=6b4f9c3ef54450dd9c3953e19a4416ef#p24002
Range(start, stop:="", step:=1) {
	static range := { _NewEnum: Func("_RangeNewEnum") }
	if !step {
		throw "range(): Parameter 'step' must not be 0 or blank"
	}
	if (stop == "") {
		stop := start, start := 0
	}
	; Formula: r[i] := start + step*i ; r = range object, i = 0-based index
	; For a postive 'step', the constraints are i >= 0 and r[i] < stop
	; For a negative 'step', the constraints are i >= 0 and r[i] > stop
	; No result is returned if r[0] does not meet the value constraint
	if (step > 0 && start < stop || step < 0 && start > stop) {
		return { base: range, start: start, stop: stop, step: step }
	}
}

_RangeNewEnum(r) {
	static enum := { "Next": Func("_RangeEnumNext") }
	return { base: enum, r: r, i: 0 }
}

_RangeEnumNext(enum, ByRef current, ByRef v:="") {
	stop := enum.r.stop
	step := enum.r.step
	current := enum.r.start + step * enum.i
	if ((step > 0 && current < stop) || (step < 0 && current > stop)) {
		enum.i += 1
		return true
	} else {
		return false
	}
}

RangeAscii(startLetter, stopLetter) {
	static range := { _NewEnum: Func("_RangeAsciiNewEnum") }
	start := Asc(startLetter)
	stop := Asc(stopLetter)
	step := start < stop ? 1 : -1
	return { base: range, start: start, stop: stop, step: step }
}

_RangeAsciiNewEnum(r) {
	static enum := { "Next": Func("_RangeAsciiEnumNext") }
	return { base: enum, r: r, i: 0 }
}

_RangeAsciiEnumNext(enum, ByRef current, ByRef v:="") {
	stop := enum.r.stop
	step := enum.r.step
	value := enum.r.start + step * enum.i
	current := Chr(value)
	if ((step > 0 && value < stop) || (step < 0 && value > stop)) {
		enum.i += 1
		return true
	} else {
		return false
	}
}
