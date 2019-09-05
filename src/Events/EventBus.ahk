#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

class EventBus {
    _subscribers := {}

    ; Subscribe to all emissions of event named `eventName`.
    ; Returned value can be used to unsubscribe.
    Subscribe(eventName, subscriber) {
        if (!this._subscribers.HasKey(eventName)) {
            this._subscribers[eventName] := new this._Event()
        }
        key := RandomString(8) ; for 1000 subscribers collision probability is ~ 1e-8 - acceptable risk
        subscriberList := this._subscribers[eventName].everytime[key] := subscriber
        return { eventName: eventName, key: key, kind: "everytime" }
    }

    Unsubscribe(subscription) {
        eventName := subscription.eventName
        kind := subscription.kind
        key := subscription.key
        this._subscribers[eventName][kind].Delete(key)

    }

    ; Subscribe to nect emission of event named `eventName`.
    ; After first event is emitted, subscriber is automatically unsubscribed.
    ; Returned value can be used to unsubscribe before the event is emitted.
    SubscribeOnce(eventName, subscriber) {
        if (!this._subscribers.HasKey(eventName)) {
            this._subscribers[eventName] := new this._Event()
        }
        this._subscribers[eventName].once[key] := subscriber
        key := RandomString(8)
        subscriberList := this._subscribers[eventName].once[key] := subscriber
        return { eventName: eventName, key: key, kind: "once" }
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