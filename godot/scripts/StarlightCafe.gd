extends Node2D

const TILE := Vector2(64, 32)
const CAFE_ORIGIN := Vector2(190, 108)

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    draw_floor_grid()
    draw_cafe_shell()
    draw_furniture()
    draw_player_placeholder()

func diamond(center: Vector2, half_w: float, half_h: float, color: Color) -> void:
    var pts := PackedVector2Array([
        center + Vector2(0, -half_h),
        center + Vector2(half_w, 0),
        center + Vector2(0, half_h),
        center + Vector2(-half_w, 0)
    ])
    draw_colored_polygon(pts, color)

func draw_floor_grid() -> void:
    for y in range(-3, 7):
        for x in range(-3, 9):
            var p := CAFE_ORIGIN + Vector2((x - y) * TILE.x * 0.5, (x + y) * TILE.y * 0.5)
            diamond(p, TILE.x * 0.5, TILE.y * 0.5, Color("#355246"))

func draw_cafe_shell() -> void:
    var wall := Color("#6e4a5f")
    for i in range(7):
        var p := CAFE_ORIGIN + Vector2(i * TILE.x * 0.5, -3 * TILE.y * 0.5)
        draw_line(p + Vector2(-32, 0), p + Vector2(32, 0), wall, 8.0)
    for i in range(7):
        var p := CAFE_ORIGIN + Vector2(i * TILE.x * 0.5, 3 * TILE.y * 0.5)
        draw_line(p + Vector2(-32, 0), p + Vector2(32, 0), wall, 8.0)

func draw_furniture() -> void:
    draw_rect(Rect2(CAFE_ORIGIN + Vector2(-72, -22), Vector2(72, 28)), Color("#8f5f3e"))
    draw_rect(Rect2(CAFE_ORIGIN + Vector2(42, 8), Vector2(32, 18)), Color("#9f714a"))
    for p in [Vector2(-30, 8), Vector2(10, 8), Vector2(50, 40)]:
        draw_circle(CAFE_ORIGIN + p, 7.0, Color("#b57e7e"))

func draw_player_placeholder() -> void:
    draw_circle(CAFE_ORIGIN + Vector2(4, 30), 7.0, Color("#f2c19b"))
    draw_rect(Rect2(CAFE_ORIGIN + Vector2(-4, 37), Vector2(8, 14)), Color("#c96a84"))
    draw_line(CAFE_ORIGIN + Vector2(0, 50), CAFE_ORIGIN + Vector2(-5, 58), Color("#392b3e"), 2.0)
    draw_line(CAFE_ORIGIN + Vector2(2, 50), CAFE_ORIGIN + Vector2(8, 58), Color("#392b3e"), 2.0)
