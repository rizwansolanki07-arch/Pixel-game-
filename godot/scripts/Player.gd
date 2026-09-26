extends CharacterBody2D

const SPEED := 78.0
var facing := Vector2.DOWN
var walk_time := 0.0

func _physics_process(delta: float) -> void:
    var keyboard_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var input_vector := keyboard_input
    if GameState.touch_move.length() > 0.05:
        input_vector = GameState.touch_move

    if input_vector.length() > 0.0:
        velocity = input_vector.normalized() * SPEED
        walk_time += delta * 9.0
        if abs(input_vector.x) > abs(input_vector.y):
            facing = Vector2(sign(input_vector.x), 0)
        else:
            facing = Vector2(0, sign(input_vector.y))
    else:
        velocity = Vector2.ZERO
        walk_time = 0.0

    move_and_slide()
    global_position.x = clamp(global_position.x, 18.0, 366.0)
    global_position.y = clamp(global_position.y, 36.0, 204.0)
    queue_redraw()

func _draw() -> void:
    # Hand-authored pixel character: readable silhouette at 16px-grid scale.
    var bob := 0.0
    if velocity.length() > 0.1:
        bob = sin(walk_time) * 0.7

    # Ground shadow.
    draw_ellipse(Vector2(0, 12), Vector2(7, 2), Color(0, 0, 0, 0.25))

    # Hair and head.
    draw_rect(Rect2(-6, -11 + bob, 12, 10), Color("#2b1c2e"))
    draw_rect(Rect2(-5, -7 + bob, 10, 9), Color("#f0c3a0"))
    draw_rect(Rect2(-6, -9 + bob, 12, 4), Color("#3a2236"))
    draw_rect(Rect2(-5, -4 + bob, 2, 2), Color("#3a2725"))
    draw_rect(Rect2(3, -4 + bob, 2, 2), Color("#3a2725"))

    # Purple kurta with warm trim.
    draw_rect(Rect2(-7, 2 + bob, 14, 10), Color("#7b3f68"))
    draw_rect(Rect2(-7, 2 + bob, 14, 2), Color("#a95b7d"))
    draw_rect(Rect2(-2, 4 + bob, 4, 7), Color("#623052"))

    # Legs and sandals.
    draw_rect(Rect2(-6, 11 + bob, 5, 4), Color("#40334e"))
    draw_rect(Rect2(1, 11 + bob, 5, 4), Color("#40334e"))
    draw_rect(Rect2(-7, 14 + bob, 6, 2), Color("#b27a4c"))
    draw_rect(Rect2(1, 14 + bob, 6, 2), Color("#b27a4c"))

    # Facing cue.
    if facing.x > 0:
        draw_rect(Rect2(5, -5 + bob, 2, 2), Color("#33221f"))
    elif facing.x < 0:
        draw_rect(Rect2(-7, -5 + bob, 2, 2), Color("#33221f"))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var points := PackedVector2Array()
    for i in range(16):
        var a := TAU * float(i) / 16.0
        points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
    draw_colored_polygon(points, color)
