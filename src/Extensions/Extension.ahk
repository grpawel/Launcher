; Interface for extensions. 
; Extension can add or change some functionalities for given controller.
; Each controller will get separate objects of this class.
class Extension {
    ; Name of extension, used to refer to it.
    static NAME := ""

    ; Set up settings.
    Attach(contr, settings) {
    }

    ; Add functionality to controller.
    ; `extensions` - list of all extensions attached to given controller, in form of map from name to object.
    Activate(extensions) {
    }
}
