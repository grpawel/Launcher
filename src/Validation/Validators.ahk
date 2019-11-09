#Include %A_ScriptDir%\src\Validation\SimpleValidators.ahk
#Include %A_ScriptDir%\src\Validation\CombiningValidators.ahk

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
