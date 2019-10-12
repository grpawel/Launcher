#Include %A_ScriptDir%\src\Events\Subscription.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

class EventBus {
    _subscribers := {}

    ; Subscribe to emissions of event named `eventName`.
    ; Can subscribe to all events or only single event.
    ; Subscribers are called from lowest priority; if priority is same then in no particular order.
    ; Returned value can be used to unsubscribe by calling Unsubscribe method on it.
    ;
    ; Options:
    ; duration: "everytime" - (default) subscriber is called for events until unsubscribes
    ;           "once" - subscriber is called only once, then automatically unsubscribed
    ; priority: 1-32 (default: 16) - priority of subscriber. Lower priority subscribers are called earlier.
    ; 
    ; Remark:
    ; When subscriber is added or removed in response to emitted event,
    ; the subscriber may or may not receive the event.
    ; Do not rely on apparent behavior.
    Subscribe(eventName, subscriber, options = "") {
        static V := new ValidatorFactory()
        static VAL := V.Object( { "duration": V.OneOf(["everytime", "once"])
                                , "priority": V.Between(1, 32) })
        static DEFAULT_OPTIONS = { "duration": "everytime"
                                 , "priority": 16 }
        options := MergeArrays(DEFAULT_OPTIONS, options)
        VAL.ValidateAndShow(options)

        if (!this._subscribers.HasKey(eventName)) {
            this._subscribers[eventName] := new this._SubscriberList()
        }
        key := RandomString(8) ; for 1000 subscribers collision probability is ~ 1e-8 - acceptable risk
        ; for priority we use simple trick. AHK iterates keys alphabetically, so we can add single letter
        ; from range 48 ('0') to 79 ('O'). Object keys are case insensitive, so priority range cannot be much bigger.
        key := Chr(Asc("0") + options.priority) . key
        this._subscribers[eventName][options.duration][key] := subscriber
        return new Subscription(this, { eventName: eventName, key: key, duration: options.duration })
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