#Include %A_ScriptDir%\src\Validation\Validators.ahk

class ValidatorAlwaysTrue extends BaseValidator {
    Validate(obj) {
        return ""
    }
}

class ValidatorString extends BaseValidator {
    Validate(obj) {
        ; can we check it in a better way?
        if (IsObject(obj)) {
            return "``" ToCompactString(obj) "`` is not a string."
        }
    }
}

class ValidatorBoolean extends BaseValidator {
    Validate(obj) {
        if (obj != true && obj != false) {
            return "``" ToCompactString(obj) "`` is not a boolean."
        }
    }
}

class ValidatorEmpty extends BaseValidator {
    Validate(obj) {
        if (obj != "") {
            return "``" ToCompactString(obj) "`` is not empty."
        }
    }
}

class ValidatorPositiveInt extends BaseValidator {
    Validate(obj) {
        isInteger := ValidatorInteger.Validate(obj)
        if (isInteger != "") {
            return isInteger
        }
        if (obj < 0) {
            return "``" ToCompactString(obj) "`` is not positive."
        }
    }
}

class ValidatorInteger extends BaseValidator {
    Validate(obj) {
        If obj is not integer
            return "``" ToCompactString(obj) "`` is not integer."
    }
}

class ValidatorEqual extends BaseValidator {
    _Set(expected) {
        this._expected := expected
    }

    Validate(actual) {
        if (this._expected != actual) {
            return "``" ToCompactString(actual) "`` is not equal to ``" ToCompactString(this._expected) "``."
        }
    }
}



class ValidatorOneOf extends BaseValidator {
    _Set(possibleValues) {
        this._possibleValues := possibleValues
    }

    Validate(value) {
        if (!ArrayContains(this._possibleValues, value)) {
            return "``" ToCompactString(value) "`` is not one of values " ToCompactString(this._possibleValues) . "."
        }
        return ""
    }
}

class ValidatorBetween extends BaseValidator {
    _Set(min, max) {
        this._min := min
        this._max := max
    }

    Validate(value) {
        if (value < this._min || this._max < value) {
            return "``"ToCompactString(value) "`` is not between ``" ToCompactString(this._min) "`` and ``" ToCompactString(this._max) "``."
        }
    }
}
