extends Node2D

# Yui presentation-layer character.
# Locked scale: 56 px tall = 165 cm human.
const HEIGHT := 56.0
const WIDTH := 30.0
const WALK_FPS := 8.0

var move_direction := Vector2.DOWN
var moving := false
var walk_clock := 0.0
var facing_index := 0

# 8-direction order matches the project's direction convention.
const DIRS := [
    Vector2(0, 1), Vector2(-0.707, 0.707), Vector2(-1, 0),
    Vector2(-0.707, -0.707), Vector2(0, -1), Vector2(0.707, -0.707),
    Vector2(1, 0), Vector2(0.707, 0.707)
]

func set_motion(direction: Vector2, is_moving: bool) -> void:
    if direction.length() > 0.05:
        move_direction = direction.normalized()
        facing_index = _nearest_direction(move_direction)
    moving = is_moving
    if moving:
        walk_clock += get_process_delta_time() * WALK_FPS
    else:
        walk_clock = 0.0
    queue_redraw()

func _nearest_direction(direction: Vector2) -> int:
    var best := 0
    var best_dot := -2.0
    for i in range(DIRS.size()):
        var score := direction.dot(DIRS[i])
        if score > best_dot:
            best_dot = score
            best = i
    return best

func _process(delta: float) -> void:
    if moving:
        walk_clock += delta * WALK_FPS
    queue_redraw()

func _draw() -> void:
    var frame := int(floor(walk_clock)) % 5 if moving else 0
    var bob := 0.0
    var step := 0.0
    if moving:
        bob = sin(walk_clock * TAU / 5.0) * 1.0
        step = sin(walk_clock * TAU / 5.0) * 1.8

    # Ground contact and shadow.
    draw_ellipse(Vector2(0, 26), Vector2(11, 4), Color(0.02, 0.015, 0.04, 0.30))

    # Hair silhouette — long braid is kept as a recognizable side/back cue.
    var head_y := -22.0 + bob
    draw_rect(Rect2(-11, head_y, 22, 17), Color("#1d1824"))
    draw_rect(Rect2(-9, head_y + 4, 18, 13), Color("#e7ad88"))
    draw_rect(Rect2(-10, head_y + 1, 20, 7), Color("#35202e"))
    draw_rect(Rect2(-8, head_y + 5, 16, 3), Color("#4a2935"))
    draw_rect(Rect2(-10, head_y + 8, 3, 6), Color("#2b1c2e"))
    draw_rect(Rect2(7, head_y + 8, 3, 6), Color("#2b1c2e"))
    draw_rect(Rect2(-7, head_y + 8, 2, 2), Color("#4b3028"))
    draw_rect(Rect2(5, head_y + 8, 2, 2), Color("#4b3028"))

    # Braid visible on left/back facings.
    if facing_index in [1, 2, 3, 4]:
        draw_rect(Rect2(-13, head_y + 8, 5, 12), Color("#302031"))
        draw_rect(Rect2(-14, head_y + 18, 6, 6), Color("#392438"))

    # Mustard blouse + brown laced bodice.
    var body_y := -6.0 + bob
    draw_rect(Rect2(-13, body_y + 2, 5, 9), Color("#d39a42"))
    draw_rect(Rect2(8, body_y + 2, 5, 9), Color("#d39a42"))
    draw_rect(Rect2(-11, body_y, 22, 19), Color("#d6a04a"))
    draw_rect(Rect2(-9, body_y + 2, 18, 17), Color("#704638"))
    draw_rect(Rect2(-6, body_y + 3, 12, 13), Color("#89543d"))
    draw_line(Vector2(-4, body_y + 5), Vector2(4, body_y + 5), Color("#d7a06a"), 1)
    draw_line(Vector2(-4, body_y + 8), Vector2(4, body_y + 8), Color("#d7a06a"), 1)

    # Brick-red long skirt.
    var skirt_y := 12.0 + bob
    draw_rect(Rect2(-13, skirt_y, 26, 13), Color("#a34b43"))
    draw_rect(Rect2(-15, skirt_y + 8, 30, 7), Color("#78373d"))
    draw_rect(Rect2(-11, skirt_y + 2, 3, 9), Color("#c05b4b"))
    draw_rect(Rect2(8, skirt_y + 2, 3, 9), Color("#8a3c3e"))

    # Walking leg separation, keeping a 56px silhouette.
    var leg_a := step
    var leg_b := -step
    draw_rect(Rect2(-7 + leg_a, 24, 6, 7), Color("#4a3340"))
    draw_rect(Rect2(1 + leg_b, 24, 6, 7), Color("#4a3340"))
    draw_rect(Rect2(-8 + leg_a, 30, 8, 3), Color("#a97850"))
    draw_rect(Rect2(0 + leg_b, 30, 8, 3), Color("#a97850"))

    # Directional face cue for side/back movement.
    if facing_index == 2:
        draw_rect(Rect2(-9, head_y + 9, 2, 2), Color("#30221f"))
    elif facing_index == 6:
        draw_rect(Rect2(7, head_y + 9, 2, 2), Color("#30221f"))
    elif facing_index in [0, 7, 1]:
        draw_rect(Rect2(-5, head_y + 9, 2, 2), Color("#30221f"))
        draw_rect(Rect2(3, head_y + 9, 2, 2), Color("#30221f"))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var points := PackedVector2Array()
    for i in range(20):
        var a := TAU * float(i) / 20.0
        points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
    draw_colored_polygon(points, color)
