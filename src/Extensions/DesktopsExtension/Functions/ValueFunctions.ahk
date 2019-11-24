#Include *i <windows-desktop-switcher/functions>

GetDesktop() {
    return Func("GetDesktopFunction")
}

GetDesktopFunction() {
    static MAP_DESKTOPS_FUNC := Func("mapDesktopsFromRegistry")
    MAP_DESKTOPS_FUNC.Call()
    global CurrentDesktop
    return CurrentDesktop
}

GetTotalDesktops() {
    return Func("GetTotalDesktopsFunction")
}

GetTotalDesktopsFunction() {
    static MAP_DESKTOPS_FUNC := Func("mapDesktopsFromRegistry")
    MAP_DESKTOPS_FUNC.Call()
    global DesktopCount
    return DesktopCount
}
