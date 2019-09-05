#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

class EventBus {
    _subscribers := {}

    ; Subscribe to all emissions of event named `eventName`.
    ; Returned value can be used to unsubscribe.
    ;
    ; Remark:
    ; When subscriber is added or removed in response to emitted event,
    ; the subscriber may or may not receive the event.
    ; Do not rely on observed behavior.
    Subscribe(eventName, subscriber) {
        if (!this._subscribers.HasKey(eventName)) {
            this._subscribers[eventName] := new this._SubscriberList()
        }
        key := RandomString(8) ; for 1000 subscribers collision probability is ~ 1e-8 - acceptable risk
        this._subscribers[eventName].everytime[key] := subscriber
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
            this._subscribers[eventName] := new this._SubscriberList()
        }
        key := RandomString(8)
        this._subscribers[eventName].once[key] := subscriber
        return { eventName: eventName, key: key, kind: "once" }
    }

    Emit(eventName, payload = "") {
        if (!this._subscribers.hasKey(eventName)) {
            return
        }
        subscriberList := this._subscribers[eventName]

        for key, subscriber in subscriberList.everytime.Clone() {
            %subscriber%(payload)
        }
        oneTimeSubscribers := subscriberList.once.Clone()
        for key, subscriber in oneTimeSubscribers {
            %subscriber%(payload)
            subscriberList.once.Delete(key)
        }
    }

    class _SubscriberList {
        everytime := {}
        once := {}
    }
}