class ValidatorFactory {
    __Call(validatorName, params*) {
        name := "Validator" validatorName
        val := new %name%()
        val._Set(params[1], params[2], params[3], params[4])
        if (val == "") {
            MsgBox % "Validator " validatorName " does not exist."
        }
        return val
    }
}

class BaseValidator {
    ValidateAndShow(obj) {
        result := this.Validate(obj)
        if (result != "") {
            MsgBox, %result%
        }
    }
}

class ValidatorObject extends BaseValidator {
    _Set(validatorObjByKey, options) {
        this._validatorObjByKey := validatorObjByKey
        this._noOtherKeys := options["noOtherKeys"]
        this._ignoreMissing := options["ignoreMissing"]
        static V := new ValidatorFactory()
        static VAL := V.Or( [ V.Object(   { "noOtherKeys": V.Boolean()
                                        , "ignoreMissing": V.Boolean() }
                                    , { ignoreMissing: true, noOtherKeys: true })
                            , V.Empty() ])
        VAL.ValidateAndShow(options)
    }

    Validate(obj) {
        messages := []
        if (!IsObject(obj)) {
            messages.Push("``" ToCompactString(obj) "`` is not an object.")
        }
        else {
            for key, validatorObj in this._validatorObjByKey {
                if (!obj.HasKey(key)) {
                    if (!this._ignoreMissing) {
                        messages.Push("missing key ``" key "`` in ``" ToCompactString(obj) "``.")
                    }
                    continue
                }
                value := obj[key]

                message := validatorObj.Validate(value)
                if (message != "") {
                    messages.Push("``" key "``:" message)
                }
            }
            if (this._noOtherKeys) {
                for key, v in obj {
                    if (!this._validatorObjByKey.HasKey(key)) {
                        messages.Push(" unnecessary key ``" key "`` in ``" ToCompactString(obj) "``.")
                    }
                }
            }
        }
        if (HasAnyKey(messages)) {
            return ToMultilineString(messages)
        }
    }
}

class ValidatorAlwaysTrue extends BaseValidator {
    Validate(obj) {
        return ""
    }
}

class ValidatorObjectEachValue extends BaseValidator {
    _Set(valueValidator) {
        this._valueValidator := valueValidator
    }

    Validate(obj) {
        if (!IsObject(obj)) {
            return "``" ToCompactString(obj) "`` is not an object."
        }
        messages := {}
        for key, value in obj {
            message := this._valueValidator.Validate(value)
            if (message != "") {
                messages[key] := message
            }
        }
        if (HasAnyKey(messages)) {
            return ToMultilineString(messages)
        }
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

class ValidatorOr extends BaseValidator {
    _Set(validatorObjs) {
        this._validatorObjs := validatorObjs
    }

    Validate(obj) {
        messages := []
        for i, validatorObj in this._validatorObjs {
            message := validatorObj.Validate(obj)
            if (message == "") {
                return ""
            } else {
                messages.Push(message)
            }
        }
        return "At least one of these should validate: " ToMultilineString(messages)   
    }
}

class ValidatorAnd extends BaseValidator {
    _Set(validatorObjs) {
        this._validatorObjs := validatorObjs
    }

    Validate(obj) {
        messages := []
        for i, validatorObj in this._validatorObjs {
            message := validatorObj.Validate(obj)
            if (message != "") {
                messages.Push(message)
            }
        }
        if (HasAnyKey(messages)) {
            return "All of these should validate: " ToMultilineString(messages)   
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
