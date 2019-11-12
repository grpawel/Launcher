GetDesktop() {
    return Func("GetDesktopFunction")
}

GetDesktopFunction() {
    mapDesktopsFromRegistry()
    global CurrentDesktop
    return CurrentDesktop
}

GetTotalDesktops() {
    return Func("GetTotalDesktopsFunction")
}

GetTotalDesktopsFunction() {
    mapDesktopsFromRegistry()
    global DesktopCount
    return DesktopCount
}
