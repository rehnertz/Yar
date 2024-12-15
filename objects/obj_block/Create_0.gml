ENTITY
tag = Tag.Block

/**
 * @param {Real} dx
 * @param {Real} dy
 * @returns {Array<Any>}
 * This method should be called before moving.
 */
get_drivables = function(dx, dy) {
    var drivables = []
    var list = ds_list_create()
    var d = 1
    var n = collision_rectangle_list(
        bbox_left - d, bbox_top - d,
        bbox_right + d, bbox_bottom + d,
        all, true, true, list, false
    )
    for (var i = 0; i < n; i++) {
        var inst = list[| i]
        if (inst.has_tag(Tag.Box) && inst.probe(0, 1, self, true) && !probe(dx, dy, inst, false)) {
            array_push(drivables, inst)
        }
    }
    ds_list_destroy(list)
    return drivables
}

/**
 * @param {Real} dx
 * @param {Real} dy
 * @returns {Array<Any>}
 * This method should be called before moving.
 */
get_pushables = function(dx, dy) {
    return probe_(dx, dy, Tag.Box)
}

/**
 * @param {Real} dx
 * @param {Real} dy
 * @param {Any} inst
 * This function should be called after moving.
 */
drive = function(dx, dy, inst) {
    inst.move(dx, dy)
}

/**
 * @param {Real} dx
 * @param {Real} dy
 * @param {Any} inst
 * This function should be called after moving.
 */
push = function(dx, dy, inst) {
    var d = point_distance(0, 0, dx, dy)
    dx = dx / d * inst.collision_gap
    dy = dy / d * inst.collision_gap
    while (collide_at(x, y, inst)) {
        var x0 = inst.x
        var y0 = inst.y
        instance_deactivate_object(self)
        inst.move(dx, dy)
        instance_activate_object(self)
        if (inst.x == x0 && inst.y == y0) {
            break
        }
    }
}

move = function(dx, dy) {
    var drivables = get_drivables(dx, dy)
    var pushables = get_pushables(dx, dy)
    x += dx
    y += dy
    
    var n = array_length(drivables)
    for (var i = 0; i < n; i++) {
        drive(dx, dy, drivables[i])
    }
    
    n = array_length(pushables)
    for (var i = 0; i < n; i++) {
        push(dx, dy, pushables[i])
    }
    
    return int64(0)
}
