class Browser {
    _currentBrowser := """firefox"""

    OpenWebsite(url) {
        command := this._currentBrowser " """ url """"
        Run %command%
    }

    ChangeCurrent(newBrowser) {
        this._currentBrowser := newBrowser
    }
}