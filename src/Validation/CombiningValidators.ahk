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
    static _DEFAULT_OPTIONS := { "allowMissingKeys": false
                               , "allowOtherKeys": false
                               , "allowEmptyVariable": false }

    _Set(validatorObjByKey, options) {
        this._validatorObjByKey := validatorObjByKey
        this._options := MergeArrays(this._DEFAULT_OPTIONS, options)
        static V := new ValidatorFactory()
        static VAL := V.Object({ "allowOtherKeys": V.Boolean()
                               , "allowMissingKeys": V.Boolean()
                               , "allowEmptyVariable": V.Boolean() }
                              , { allowMissingKeys: true, allowOtherKeys: false, allowEmptyVariable: true })
        VAL.ValidateAndShow(this._options)
    }

    Validate(obj) {
        messages := []
        if (!IsObject(obj) && !this._options.allowEmptyVariable) {
            messages.Push("``" ToCompactString(obj) "`` is not an object.")
        }
        else {
            for key, validatorObj in this._validatorObjByKey {
                if (!obj.HasKey(key)) {
                    if (!this._options.allowMissingKeys) {
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
            if (!this._options.allowOtherKeys) {
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