extends Node2D

# Modular café architecture layer: walls, windows, door, lamps and sign.
# Decorative only; gameplay collision remains owned by StarlightCafe.gd.

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    var night := StarlightGameState.phase == "night"
    _draw_back_wall(night)
    _draw_windows(night)
    _draw_door(night)
    _draw_lamps(night)
    _draw_sign(night)

func _draw_back_wall(night: bool) -> void:
    var wall := Color("#4a3855") if night else Color("#8c5b62")
    var trim := Color("#8e6ca8") if night else Color("#d09a61")
    # Upper wall band; leave the central play area open.
    draw_rect(Rect2(88, 48, 216, 22), wall)
    draw_rect(Rect2(88, 67, 216, 4), trim)
    # Pixel brick seams.
    for x in range(96, 300, 24):
        draw_line(Vector2(x, 51), Vector2(x, 67), Color(0.10, 0.07, 0.13, 0.28), 1.0)
    for x in range(108, 300, 48):
        draw_line(Vector2(x, 59), Vector2(x + 10, 59), Color(0.95, 0.75, 0.58, 0.12), 1.0)

func _draw_windows(night: bool) -> void:
    var frame := Color("#34283d")
    var glass := Color("#e6b85e") if not night else Color("#554b87")
    for x in [108.0, 270.0]:
        draw_rect(Rect2(x, 51, 28, 18), frame)
        draw_rect(Rect2(x + 3, 54, 22, 12), glass)
        draw_line(Vector2(x + 14, 54), Vector2(x + 14, 66), Color("#7a5960"), 2.0)
        draw_line(Vector2(x + 3, 60), Vector2(x + 25, 60), Color("#7a5960"), 2.0)
        if night:
            draw_circle(Vector2(x + 14, 60), 14.0, Color(0.48, 0.38, 0.90, 0.08))

func _draw_door(night: bool) -> void:
    var frame := Color("#302638")
    var wood := Color("#70464a") if night else Color("#9a604a")
    draw_rect(Rect2(196, 49, 34, 23), frame)
    if not get_parent().door_open:
        draw_rect(Rect2(200, 52, 26, 20), wood)
        draw_rect(Rect2(203, 55, 20, 7), Color("#b97950") if not night else Color("#80546b"))
        draw_rect(Rect2(203, 64, 20, 5), Color("#5b3941"))
        draw_circle(Vector2(220, 62), 1.5, Color("#f2ca79"))
    else:
        draw_rect(Rect2(201, 53, 24, 19), Color("#17142a"))
        draw_line(Vector2(202, 52), Vector2(202, 70), Color("#9b684c"), 3.0)
        draw_string(ThemeDB.fallback_font, Vector2(206, 64), "→", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#e7c179"))

func _draw_lamps(night: bool) -> void:
    for x in [158.0, 242.0]:
        draw_line(Vector2(x, 48), Vector2(x, 55), Color("#3b2d3e"), 2.0)
        draw_rect(Rect2(x - 4, 55, 8, 5), Color("#8a5a45"))
        draw_rect(Rect2(x - 2, 56, 4, 3), Color("#f0bd63") if not night else Color("#f3c778"))
        if night:
            draw_circle(Vector2(x, 58), 15.0, Color(0.98, 0.68, 0.32, 0.08))

func _draw_sign(night: bool) -> void:
    draw_rect(Rect2(152, 38, 80, 11), Color("#302538"))
    draw_rect(Rect2(154, 40, 76, 7), Color("#a86c55") if not night else Color("#76517b")
    )
    draw_string(ThemeDB.fallback_font, Vector2(163, 46), "STARLIGHT", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("#ffe3a5"))
