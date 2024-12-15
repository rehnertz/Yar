enum InputType {
    Down, DirectDown, Pressed, Released,
}

global.input = {
    enabled: true,
    reversed: false,
    options: {
        move_left: {
            type: InputType.DirectDown,
            key: vk_left,
            reverse: "right",
        },
        move_right: {
            type: InputType.DirectDown,
            key: vk_right,
            reverse: "left",
        },
        jump: {
            type: InputType.Pressed,
            key: vk_shift,
        },
        cancel_jump: {
            type: InputType.Released,
            key: vk_shift,
        },
        shoot: {
            type: InputType.Pressed,
            key: ord("Z"),
        },
        suicide: {
            type: InputType.Pressed,
            key: ord("Q"),
        },
    }
}

function input_check(action) {
    if (!global.input.enabled) {
        return false
    }
    
    var option = global.input.options[$ action]
    if (global.input.reversed && struct_exists(option, reverse)) {
        option = global.input.options[$ option.reverse]
    }
    
    static check = function(type, key) {
        switch (type) {
            case InputType.DirectDown:
                return keyboard_check_direct(key)
            case InputType.Pressed:
                return keyboard_check_pressed(key)
            case InputType.Released:
                return keyboard_check_released(key)
            default:
                return keyboard_check(key)
        }
    }
    
    if (!is_array(option.key)) {
        return check(option.type, option.key)
    }
    
    var n = array_length(option.key)
    for (var i = 0; i < n; i++) {
        if (check(option.type, option.key[i])) {
            return true
        }
    }
    return false
}
