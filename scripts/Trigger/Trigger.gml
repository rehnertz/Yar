global.trigger_index = -1

function set_trigger(options = {}) {
    trigger = _resolve_trigger_options(options)
}

function _resolve_trigger_options(options = {}) {
    if (is_array(options)) {
        var n = array_length(options)
        var triggers = array_create(n)
        for (var i = 0; i < n; i++) {
            triggers[i] = _resolve_trigger_options(options[i])
        }
        return new TriggerSequence(triggers)
    } else {
        options.target = self
        var trigger_constructor = options.trigger
        var delay = options[$ "delay"]
        var trigger = new trigger_constructor(options)
        if (delay) {
            trigger = new TriggerDelayed(trigger, delay)
        }
        return trigger
    }
}

enum TriggerState {
    Inactive, Running, Finished
}

function Trigger(options = {}) constructor {
    index = options[$ "index"] ?? -1
    state = TriggerState.Inactive
    target = options.target
    
    static get_index = function() {
        return index
    }
    
    static get_state = function() {
        return state
    }
    
    static on_start = nop
    static on_update = nop
    static on_finish = nop
    
    static update = function() {
        if (state == TriggerState.Inactive) {
            if (index < 0 || index <= global.trigger_index) {
                on_start()
                state = TriggerState.Running
            }
        }
        if (state == TriggerState.Running) {
            on_update()
        }
    }
    
    static finish = function() {
        if (state == TriggerState.Running) {
            on_finish()
            state = TriggerState.Finished
        }
    }
}

function TriggerSequence(triggers) constructor {
    self.triggers = triggers
    seq_idx = 0
    
    static get_index = function() {
        var n = array_length(triggers)
        if (seq_idx < n) {
            return triggers[seq_idx].get_index()
        }
        return -1
    }
    
    static get_state = function() {
        var n = array_length(triggers)
        if (seq_idx < n) {
            return seq[seq_idx].get_state()
        }
        return TriggerState.Finished
    }
    
    static update = function() {
        var n = array_length(triggers)
        if (seq_idx >= n) {
            return
        }
        var trigger = triggers[seq_idx]
        trigger.update()
        if (trigger.get_state() == TriggerState.Finished) {
            seq_idx++
        }
    }
}

function TriggerDelayed(trigger, delay) constructor {
    self.trigger = trigger
    self.delay = delay
    started = false
    pending = false
    
    static get_index = function() {
        return trigger.get_index()
    }
    
    static get_state = function() {
        if (!started) {
            return TriggerState.Inactive
        }
        if (pending) {
            return TriggerState.Running
        }
        return trigger.get_state()
    }
    
    static update = function() {
        if (!started) {
            var index = get_index()
            if (index < 0 || index <= global.trigger_index) {
                pending = true
                started = true
                call_later(
                    delay,
                    time_source_units_seconds,
                    function() {
                        pending = false
                    }
                )
            }
        }
        if (!pending) {
            trigger.update()
        }
    }
}

function TriggerTranslate(options = {}) : Trigger(options) constructor {
    loop = options[$ "loop"] ?? false
    reverse = options[$ "reverse"] ?? false
    dx = options[$ "dx"] ?? 0
    dy = options[$ "dy"] ?? 0
    duration = options.duration
    timer = 0
    ease = options[$ "ease"]
    
    static on_start = function() {
        start_x = target.x
        start_y = target.y
        end_x = target.x + dx
        end_y = target.y + dy
    }
    
    static on_update = function() {
        timer += delta_time / 1000000
        
        var progress = timer / duration
        var t = progress
        if (reverse) {
            t = clamp(1 - abs(1 - 2 * t), 0, 1)
        }
        if (is_callable(ease)) {
            t = ease(t)
        }
        
        var target_x = lerp(start_x, end_x, t)
        var target_y = lerp(start_y, end_y, t)
        target.move(target_x - target.x, target_y - target.y)
        if (progress >= 1) {
            if (loop) {
                timer = 0
            } else {
                finish()
            }
        }
    }
}
