GetDesktop() {
    return Func("GetDesktopFunction")
}

GetDesktopFunction() {
    mapDesktopsFromRegistry()
    global CurrentDesktop
    return CurrentDesktop
}
