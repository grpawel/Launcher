#Include %A_ScriptDir%\src\Validation\Validators.ahk

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
                    messages.Push("``" key "``: " message)
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