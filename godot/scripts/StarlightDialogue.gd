extends Node2D

signal finished

var active := false
var speaker := ""
var lines: Array[String] = []
var index := 0

func _ready() -> void:
    z_index = 50
    queue_redraw()

func begin(speaker_name: String, dialogue_lines: Array[String]) -> void:
    speaker = speaker_name
    lines = dialogue_lines.duplicate()
    index = 0
    active = lines.size() > 0
    queue_redraw()

func advance() -> void:
    if not active:
        return
    index += 1
    if index >= lines.size():
        active = false
        finished.emit()
    queue_redraw()

func _input(event: InputEvent) -> void:
    if not active:
        return
    if event.is_action_pressed("interact"):
        advance()
        get_viewport().set_input_as_handled()
    elif event is InputEventScreenTouch and event.pressed:
        advance()
        get_viewport().set_input_as_handled()

func _draw() -> void:
    if not active:
        return
    var font := ThemeDB.fallback_font
    draw_rect(Rect2(18, 130, 348, 72), Color(0.035, 0.025, 0.07, 0.96))
    draw_rect(Rect2(20, 132, 344, 68), Color("#5c4566"), false, 2.0)
    draw_rect(Rect2(30, 140, 74, 18), Color("#9c6f99"))
    draw_string(font, Vector2(40, 153), speaker, HORIZONTAL_ALIGNMENT_LEFT, 58, 9, Color("#fff0c4"))
    var line: String = lines[index]
    draw_string(font, Vector2(32, 171), line, HORIZONTAL_ALIGNMENT_LEFT, 316, 9, Color("#f3e7d2"))
    draw_string(font, Vector2(318, 190), "E / TAP", HORIZONTAL_ALIGNMENT_LEFT, 45, 7, Color("#d9cde4"))
