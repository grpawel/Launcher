#Include %A_ScriptDir%\src\Events\Subscription.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

class EventBus {
    _subscribers := {}

    ; Subscribe to emissions of event named `eventName`.
    ; Can subscribe to all events until unsubscribe or only next one. (duration: everytime|once)
    ; Returned value can be used to unsubscribe by calling Unsubscribe method on it.
    ;
    ; Remark:
    ; When subscriber is added or removed in response to emitted event,
    ; the subscriber may or may not receive the event.
    ; Do not rely on apparent behavior.
    Subscribe(eventName, subscriber, duration = "everytime") {
        if (!ArrayContains(["everytime", "once"], duration)) {
            Throw % "Invalid argument: '" duration "'."
        }
        if (!this._subscribers.HasKey(eventName)) {
            this._subscribers[eventName] := new this._SubscriberList()
        }
        key := RandomString(8) ; for 1000 subscribers collision probability is ~ 1e-8 - acceptable risk
        this._subscribers[eventName][duration][key] := subscriber
        return new Subscription(this, { eventName: eventName, key: key, duration: duration })
    }

    ; Shortcut method.
    ; Argument `subscriber` can be long - last argument "Once" could be missed.
    SubscribeOnce(eventName, subscriber) {
        return this.Subscribe(eventName, subscriber)
    }

    ; To be called by `Subscription` object.
    ; To unsubscribe, call `Unsubscribe` on object returned from `EventBus.Subscribe()`.
    _Unsubscribe(params) {
        eventName := params.eventName
        duration := params.duration
        key := params.key
        this._subscribers[eventName][duration].Delete(key)
    }

    Emit(eventName, payload*) {
        if (!this._subscribers.hasKey(eventName)) {
            return
        }
        subscriberList := this._subscribers[eventName]

        for key, subscriber in subscriberList.everytime.Clone() {
            %subscriber%(payload*)
        }
        oneTimeSubscribers := subscriberList.once.Clone()
        for key, subscriber in oneTimeSubscribers {
            %subscriber%(payload*)
            subscriberList.once.Delete(key)
        }
    }

    class _SubscriberList {
        everytime := {}
        once := {}
    }
}