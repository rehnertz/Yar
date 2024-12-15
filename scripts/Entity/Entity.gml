enum Tag {
    None = 0,
    Block = 1,
    Platform = 2,
    Obstacle = 3,  // Block | Platform
    Killer = 4,
    Box = 8,
    Vine = 16,
}

global.down_x = 0
global.down_y = 1

#macro ENTITY                                                                    \
    down_x = undefined                                                           \
    down_y = undefined                                                           \
    collision_gap = 0.5                                                          \
    tag = Tag.None                                                               \
    substep = max((bbox_right - bbox_left) / 2, (bbox_bottom - bbox_top) / 2, 1) \
    get_down_x = entity_get_down_x                                               \
    get_down_y = entity_get_down_y                                               \
    has_tag = entity_has_tag                                                     \
    collide_at = entity_collide_at                                               \
    collide_at_ = entity_collide_at_                                             \
    probe = entity_probe                                                         \
    probe_ = entity_probe_                                                       \
    translate = entity_translate                                                 \
    translate_orthogonal = entity_translate_orthogonal                           \
    move = entity_move_default                                                   \
    trigger = { update: nop }

function entity_get_down_x() {
    return down_x ?? global.down_x
}

function entity_get_down_y() {
    return down_y ?? global.down_y
}

function entity_has_tag(tag, inst = self) {
    var inst_tag = variable_instance_get(inst, "tag")
    if (!is_int64(inst_tag)) {
        return false
    }
    var mask = tag & inst_tag
    
    // Special check for platform.
    if ((mask & Tag.Platform) != 0) {
        // Estimated upper bound of distance to touch the platform.
        var dist = point_distance(
            min(bbox_left, inst.bbox_left),
            min(bbox_top, inst.bbox_top),
            max(bbox_right, inst.bbox_right),
            max(bbox_bottom, inst.bbox_bottom)
        )
        if (!entity_probe(0, dist, inst, true)) {
            mask &= ~Tag.Platform
        }
    }
    
    return mask != 0
}

function entity_collide_at(x, y, obj_or_tag) {
    if (!is_int64(obj_or_tag)) {
        // Test obj.
        return place_meeting(x, y, obj_or_tag)
    }
    
    // Test tag.
    var list = ds_list_create()
    var n = instance_place_list(x, y, all, list, false)
    var has_collided = false
    for (var i = 0; i < n; i++) {
        var inst = list[| i]
        if (entity_has_tag(obj_or_tag, inst)) {
            has_collided = true
            break
        }
    }
    ds_list_destroy(list)
    return has_collided
}

function entity_collide_at_(x, y, obj_or_tag, ordered = false, out = undefined) {
    out ??= []
    var list = ds_list_create()
    if (!is_int64(obj_or_tag)) {
        // Test obj.
        var n = instance_place_list(x, y, obj_or_tag, list, ordered)
        for (var i = 0; i < n; i++) {
            array_push(out, list[| i])
        }
    } else {
        // Test tag.
        var n = instance_place_list(x, y, all, list, ordered)
        for (var i = 0; i < n; i++) {
            var inst = list[| i]
            if (entity_has_tag(obj_or_tag, inst)) {
                array_push(out, inst)
            }
        }
    }
    ds_list_destroy(list)
    return out
}

function entity_probe(dx, dy, obj_or_tag, local = false) {
    var down_x = entity_get_down_x()
    var down_y = entity_get_down_y()
    var gdx = dx, gdy = dy
    // Convert local to global.
    if (local) {
        var ldx = dx, ldy = dy
        gdx = dot_product(down_y, down_x, ldx, ldy)
        gdy = dot_product(-down_x, down_y, ldx, ldy)
    }
    
    if (entity_collide_at(x, y, obj_or_tag)) {
        return true
    }
    var dist = point_distance(0, 0, gdx, gdy)
    if (dist == 0) {
        return false
    }
    
    var ux = gdx / dist
    var uy = gdy / dist
    var probe_x = x
    var probe_y = y
    while (dist > 0) {
        var step = min(substep, dist)
        probe_x += step * ux
        probe_y += step * uy
        if (entity_collide_at(probe_x, probe_y, obj_or_tag)) {
            return true
        }
        dist -= step
    }
    
    return false
}

function entity_probe_(dx, dy, obj_or_tag, local = false, ordered = false, out = undefined) {
    var down_x = entity_get_down_x()
    var down_y = entity_get_down_y()
    var gdx = dx, gdy = dy
    // Convert local to global.
    if (local) {
        var ldx = dx, ldy = dy
        gdx = dot_product(down_y, down_x, ldx, ldy)
        gdy = dot_product(-down_x, down_y, ldx, ldy)
    }
    
    out ??= []
    var out_initial_index = array_length(out)
    var out_start_index = out_initial_index
    var out_end_index = out_start_index
    
    entity_collide_at_(x, y, obj_or_tag, ordered, out)
    
    var dist = point_distance(0, 0, gdx, gdy)
    if (dist == 0) {
        return out
    }
    
    // Deactivate probed.
    out_end_index = array_length(out)
    for (var i = out_start_index; i < out_end_index; i++) {
        instance_deactivate_object(out[i])
    }
    out_start_index = out_end_index
    
    var ux = gdx / dist
    var uy = gdy / dist
    var probe_x = x
    var probe_y = y
    while (dist > 0) {
        var step = min(substep, dist)
        probe_x += step * ux
        probe_y += step * uy
        entity_collide_at_(probe_x, probe_y, obj_or_tag, ordered, out)
        
        // Deactivate probed.
        out_end_index = array_length(out)
        for (var i = out_start_index; i < out_end_index; i++) {
            instance_deactivate_object(out[i])
        }
        out_start_index = out_end_index
        
        dist -= step
    }
    
    for (var i = out_initial_index; i < out_end_index; i++) {
        instance_activate_object(out[i])
    }
    
    return out
}

function entity_translate(dx, dy, local = false) {
    var down_x = entity_get_down_x()
    var down_y = entity_get_down_y()
    var gdx = dx, gdy = dy
    // Convert local to global.
    if (local) {
        var ldx = dx, ldy = dy
        gdx = dot_product(down_y, down_x, ldx, ldy)
        gdy = dot_product(-down_x, down_y, ldx, ldy)
    }
    
    if (entity_collide_at(x, y, Tag.Obstacle)) {
        return true
    }
    
    var dist = point_distance(0, 0, gdx, gdy)
    if (dist == 0) {
        return false
    }
    var ux = gdx / dist
    var uy = gdy / dist
    var has_collided = false
    while (dist > 0) {
        var step = min(substep, dist)
        var probe_x = x + step * ux
        var probe_y = y + step * uy
        if (entity_collide_at(probe_x, probe_y, Tag.Obstacle)) {
            has_collided = true
            break
        }
        x = probe_x
        y = probe_y
        dist -= step
    }
    
    if (has_collided) {
        // Touch to obstacle.
        var gap = dist  // Upper bound of actual gap.
        while (gap > collision_gap) {
            var step = gap / 2
            var probe_x = x + step * ux
            var probe_y = y + step * uy
            if (!entity_collide_at(probe_x, probe_y, Tag.Obstacle)) {
                x = probe_x
                y = probe_y
            }
            gap /= 2
        }
    }
    
    return has_collided
}

function entity_translate_orthogonal(dx, dy, local = false) {
    var down_x = entity_get_down_x()
    var down_y = entity_get_down_y()
    var x0 = x, y0 = y
    if (!entity_translate(dx, dy, local)) {
        return int64(0)
    }
    
    var gdx = x - x0
    var gdy = y - y0
    // Convert actual global displacement to local.
    var ldx = dot_product(down_y, -down_x, gdx, gdy)
    var ldy = dot_product(down_x, down_y, gdx, gdy)
    var mask_x = int64(entity_translate(ldx, 0, true))
    var mask_y = int64(entity_translate(0, ldy, true))
    return (mask_y << 1) | mask_x
}

function _entity_move_on_slope(ldx) {
    var down_x = entity_get_down_x()
    var down_y = entity_get_down_y()
    var xdir = sign(ldx)
    var v = abs(ldx)
    var floor_snap = 2 * v
    var gdx = down_y * ldx
    var gdy = -down_x * ldx
    var prev_down_dx = gdx
    var prev_down_dy = gdy
    var prev_up_col = entity_collide_at(x + gdx, y + gdy, Tag.Obstacle)
    var prev_down_col = prev_up_col
    
    for (var angle = 3; angle < 90; angle += 3) {
        var c = dcos(angle)
        var s = xdir * dsin(angle)
        var up_dx = dot_product(c, s, gdx, gdy)
        var up_dy = dot_product(-s, c, gdx, gdy)
        var up_col = entity_collide_at(x + up_dx, y + up_dy, Tag.Obstacle)
        var down_dx = dot_product(c, -s, gdx, gdy)
        var down_dy = dot_product(s, c, gdx, gdy)
        var down_col = entity_collide_at(x + down_dx, y + down_dy, Tag.Obstacle)
        
        if (!prev_down_col && down_col) {
            var x0 = x, y0 = y
            x += prev_down_dx
            y += prev_down_dy
            if (entity_translate(0, floor_snap, true)) {
                return false
            }
            x = x0
            y = y0
        }
        
        if (prev_up_col && !up_col) {
            x += up_dx
            y += up_dy
            entity_translate(0, floor_snap, true)
            return false
        }
    }
    
    return entity_translate(gdx, gdy)
}

function entity_move_default(dx, dy) {
    var down_x = entity_get_down_x()
    var down_y = entity_get_down_y()
    var gdx = dx
    var gdy = dy
    var ldx = dot_product(down_y, -down_x, gdx, gdy)
    var ldy = dot_product(down_x, down_y, gdx, gdy)
    
    if (ldy >= 0 && entity_probe(0, 1, Tag.Obstacle, true)) {
        // On ground.
        var mask_x = int64(_entity_move_on_slope(ldx))
        var mask_y = int64(ldy > 0)
        return (mask_y << 1) | mask_x
    } else {
        // Off ground.
        return entity_translate_orthogonal(gdx, gdy)
    }
}
