class Browser {
    __New(browserName) {
        this._browser := browserName
    }

    OpenWebsite(url) {
        if (this._browser <> "") {
            command := this._browser " """ url """"
        }
        else {
            command := url
        }
        Run, %command%
    }
}