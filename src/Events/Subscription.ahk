class Subscription {

    __New(eventBus, params) {
        this._eventBus := eventBus
        this._params := params
        this._isUnsubscribed := false
    }

    Unsubscribe() {
        if (this._isUnsubscribed) {
            Throw, "Cannot unsubscribe twice."
        }
        this._eventBus._Unsubscribe(this._params)
        this._isUnsubscribed := true
        this._eventBus := ""
        this._params := ""
    }
}