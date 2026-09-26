extends CharacterBody2D

const SPEED := 78.0
var facing := Vector2.DOWN

func _physics_process(_delta: float) -> void:
    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if input_vector.length() > 0.0:
        velocity = input_vector.normalized() * SPEED
        if abs(input_vector.x) > abs(input_vector.y):
            facing = Vector2(sign(input_vector.x), 0)
        else:
            facing = Vector2(0, sign(input_vector.y))
    else:
        velocity = Vector2.ZERO
    move_and_slide()
    global_position.x = clamp(global_position.x, 18.0, 366.0)
    global_position.y = clamp(global_position.y, 30.0, 205.0)
    queue_redraw()

func _draw() -> void:
    # 16px-grid pixel-art placeholder protagonist; replaceable by supplied sprite sheet.
    draw_rect(Rect2(-5, -10, 10, 12), Color("#f1c7a5"))
    draw_rect(Rect2(-6, -2, 12, 11), Color("#7d3f65"))
    draw_rect(Rect2(-7, 8, 5, 5), Color("#40334e"))
    draw_rect(Rect2(2, 8, 5, 5), Color("#40334e"))
    draw_rect(Rect2(-7, -12, 14, 5), Color("#2b1c2e"))
    if facing.x != 0:
        draw_rect(Rect2(5 * facing.x - 1, -7, 2, 2), Color("#33221f"))
