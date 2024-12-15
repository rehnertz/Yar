var dt = delta_time / 1000000

if (attached == undefined) {
    vy += grav * dt
    if (translate(vx * dt, vy * dt, true)) {
        var obstacles = probe_(vx * dt, vy * dt, Tag.Obstacle, true, true)
        if (array_length(obstacles) > 0) {
            attached = obstacles[0]
            attached_dx = x - attached.x
            attached_dy = y - attached.y
        }
    }
}

if (attached != undefined) {
    x = attached.x + attached_dx
    y = attached.y + attached_dy
}
