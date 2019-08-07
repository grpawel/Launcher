class EventBus {
    _subscribers := {}

    Subscribe(eventName, subscriber) {
        if (!this._subscribers.HasKey(eventName)) {
            this._subscribers[eventName] := new this._Event()
        }
        this._subscribers[eventName].everytime.Push(subscriber)
    }

    SubscribeOnce(eventName, subscriber) {
        if (!this._subscribers.HasKey(eventName)) {
            this._subscribers[eventName] := new this._Event()
        }
        this._subscribers[eventName].once.Push(subscriber)
    }

    Emit(eventName, payload = "") {
        if (!this._subscribers.hasKey(eventName)) {
            return
        }
        for i, subscriber in this._subscribers[eventName].everytime {
            %subscriber%(payload)
        }
        for i, subscriber in this._subscribers[eventName].once {
            %subscriber%(payload)
        }
        this._subscribers[eventName].once := []
    }

    class _Event {
        everytime := []
        once := []
    }
}