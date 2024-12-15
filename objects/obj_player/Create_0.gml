ENTITY
tag = Tag.Box

move_speed = 150
max_fall_speed = 450
grav = 1000
jumps = [425, 350]
skin = {
    idle: spr_player_idle,
    run: spr_player_run,
    jump: spr_player_jump,
    fall: spr_player_fall,
    slide: spr_player_slide,
}

vx = 0
vy = 0
jump_level = 1
face = 1

jump = function() {
    var n = array_length(jumps)
    if (jump_level >= n) {
        return
    }
    vy = -jumps[jump_level++]
}

kill = function() {
    var gen_blood = function() {
        show_debug_message(current_time)
        repeat (40) {
            instance_create_depth(x, y, depth, obj_blood)
        }
    }
    
    gen_blood()
    var ts = call_later(0.2, time_source_units_seconds, gen_blood, true)
    call_later(0.4, time_source_units_seconds, method({ ts }, function() {
        call_cancel(ts)
    }))
    
    instance_destroy()
}
