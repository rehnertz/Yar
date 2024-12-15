/*
 * Easing functions from https://easings.net/.
 */

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_sine(t) {
    return 1 - cos(t * pi / 2)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_out_sine(t) {
    return sin(t * pi / 2)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_out_sine(t) {
    return -(cos(pi * t) - 1) / 2
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_quad(t) {
    return sqr(t)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_out_quad(t) {
    return 1 - sqr(1 - t)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_out_quad(t) {
    return (t < 0.5) ? (2 * t * t) : (1 - sqr(-2 * t + 2) / 2)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_cubic(t) {
    return cubic(t)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_out_cubic(t) {
    return 1 - cubic(1 - t)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_out_cubic(t) {
    return (t < 0.5) ? (4 * cubic(t)) : (1 - cubic(-2 * t + 2) / 2)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_quart(t) {
    return quartic(t)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_out_quart(t) {
    return 1 - quartic(1 - t)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_out_quart(t) {
    return (t < 0.5) ? (8 * quartic(t)) : (1 - quartic(-2 * t + 2) / 2)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_quint(t) {
    return quintic(t)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_out_quint(t) {
    return 1 - quintic(1 - t)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_out_quint(t) {
    return (t < 0.5) ? (16 * quintic(t)) : (1 - quintic(-2 * t + 2) / 2)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_expo(t) {
    return (t == 0) ? 0 : power(2, 10 * t - 10)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_out_expo(t) {
    return (t == 1) ? 1 : (1 - power(2, -10 * t))
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_out_expo(t) {
    if (t == 0) {
        return 0
    }
    if (t == 1) {
        return 1
    }
    if (t < 0.5) {
        return power(2, 20 * t - 10) / 2
    }
    return (2 - power(2, -20 * t + 10)) / 2
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_circ(t) {
    return 1 - sqrt(1 - sqr(t))
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_out_circ(t) {
    return sqrt(1 - sqr(t - 1))
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_out_circ(t) {
    if (t < 0.5) {
        return (1 - sqrt(1 - sqr(2 * t))) / 2
    }
    return (sqrt(1 - sqr(-2 * t + 2)) + 1) / 2
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_back(t) {
    static c1 = 1.70158
    static c3 = c1 + 1
    return c3 * cubic(t) - c1 * sqr(t)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_out_back(t) {
    static c1 = 1.70158
    static c3 = c1 + 1
    return 1 + c3 * cubic(t - 1) + c1 * sqr(t - 1)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_out_back(t) {
    static c1 = 1.70158
    static c2 = c1 * 1.525
    if (t < 0.5) {
        return sqr(2 * t) * ((c2 + 1) * 2 * t - c2) / 2
    }
    return (sqr(2 * t - 2) * ((c2 + 1) * (t * 2 - 2) * c2) + 2) / 2
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_elastic(t) {
    static c4 = 2 * pi / 3
    
    if (t == 0) {
        return 0
    }
    if (t == 1) {
        return 1
    }
    return -power(2, 10 * t - 10) * sin((t * 10 - 10.75) * c4)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_out_elastic(t) {
    static c4 = 2 * pi / 3
    
    if (t == 0) {
        return 0
    }
    if (t == 1) {
        return 1
    }
    return power(2, -10 * t) * sin((t * 10 - 0.75) * c4) + 1
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_out_elastic(t) {
    static c5 = 2 * pi / 4.5
    
    if (t == 0) {
        return 0
    }
    if (t == 1) {
        return 1
    }
    if (t < 0.5) {
        return -(power(2, 20 * t - 10) * sin((20 * t - 11.125) * c5)) / 2
    }
    return (power(2, -20 * t + 10) * sin((20 * t - 11.125) * c5)) / 2 + 1
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_bounce(t) {
    return 1 - ease_out_bounce(1 - t)
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_out_bounce(t) {
    static n1 = 7.5625
    static d1 = 2.75
    
    if (t < 1 / d1) {
        return n1 * sqr(t)
    }
    if (t < 2 / d1) {
        t -= 1.5 / d1
        return n1 * sqr(t) + 0.75
    }
    if (t < 2.5 / d1) {
        t -= 2.25 / d1
        return n1 * sqr(t) + 0.9375
    }
    t -= 2.625 / d1
    return n1 * sqr(t) + 0.984375
}

/**
 * @param {Real} t
 * @returns {Real}
 */
function ease_in_out_bounce(t) {
    if (t < 0.5) {
        return (1 - ease_out_bounce(1 - 2 * t)) / 2
    }
    return (1 + ease_out_bounce(2 * t - 1)) / 2
}
