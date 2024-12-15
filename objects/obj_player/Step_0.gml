var dt = delta_time / 1000000

if (input_check("suicide")) {
    kill()
    return
}

var left = input_check("move_left") ? 1 : 0
var right = input_check("move_right") ? 1 : 0
var xdir = right - left

var on_floor = (vy >= 0) && probe(0, 1, Tag.Obstacle, true)

if (on_floor) {
    jump_level = 0
    vy = 0
} else {
    if (jump_level == 0) {
        jump_level = 1
    }
}

if (input_check("jump")) {
    jump()
    on_floor = false
}
if (input_check("cancel_jump")) {
    vy *= 0.45
}

if (!on_floor) {
    vy += grav * dt
    if (vy > max_fall_speed) {
        vy = max_fall_speed
    }
}

vx = xdir * move_speed
if (xdir != 0) {
    face = xdir
}

var down_x = entity_get_down_x()
var down_y = entity_get_down_y()
var gdx = dot_product(down_y, down_x, vx, vy) * dt
var gdy = dot_product(-down_x, down_y, vx, vy) * dt
var mask = move(gdx, gdy)

if ((mask & 1) != 0) {
    vx = 0
}
if ((mask & 2) != 0) {
    vy = 0
}

if (on_floor) {
    sprite_index = (xdir == 0) ? skin.idle : skin.run
} else {
    sprite_index = (vy < 0) ? skin.jump : skin.fall
}

if (collide_at(x, y, Tag.Killer)) {
    kill()
}
