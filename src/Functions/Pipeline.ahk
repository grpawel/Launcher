class Pipeline {
    _steps := []

    Filter(predicate) {
        this._steps.Push({ type: "filter", predicate: predicate })
        return this
    }

    Map(mapper) {
        this._steps.Push({ type: "map", mapper: mapper })
        return this
    }

    MapKey(keyMapper) {
        this._steps.Push({ type: "mapKey", keyMapper: keyMapper })
        return this
    }

    Apply(arr) {
        for i, step in this._steps {
            if (step.type == "filter") {
                arr := this._ApplyFilter(arr, step.predicate)
            } else if (step.type == "map") {
                arr := this._ApplyMap(arr, step.mapper)
            } else if (step.type == "mapKey") {
                arr := this._ApplyMapKey(arr, step.keyMapper)
            }
        }
        return arr
    }

    _ApplyFilter(arr, predicate) {
        filtered := []
        for key, elem in arr {
            result := %predicate%(elem, key)
            if (result) {
                filtered[key] := elem
            }
        }
        return filtered
    }

    _ApplyMap(arr, mapper) {
        mapped := []
        for key, elem in arr {
            mapped[key] := %mapper%(elem, key)
        }
        return mapped
    }

    _ApplyMapKey(arr, keyMapper) {
        mapped := []
        for key, elem in arr {
            newKey := %keyMapper%(elem, key)
            mapped[newKey] := elem
        }
        return mapped
    }
}
