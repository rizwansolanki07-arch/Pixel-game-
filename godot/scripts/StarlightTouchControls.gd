extends Node2D

signal move_changed(direction: Vector2)
signal interact_pressed

const JOY_CENTER := Vector2(58, 165)
const JOY_RADIUS := 42.0
const KNOB_RADIUS := 14.0
const INTERACT_CENTER := Vector2(330, 165)
const BUTTON_RADIUS := 24.0

var active_touch := -1
var knob := JOY_CENTER
var pressed_interact := false

func _ready() -> void:
    set_process_input(true)
    queue_redraw()

func _process(_delta: float) -> void:
    queue_redraw()

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            if event.position.distance_to(JOY_CENTER) <= JOY_RADIUS * 1.35 and active_touch == -1:
                active_touch = event.index
                _update_joystick(event.position)
                get_viewport().set_input_as_handled()
            elif event.position.distance_to(INTERACT_CENTER) <= BUTTON_RADIUS * 1.5:
                interact_pressed.emit()
                pressed_interact = true
                get_viewport().set_input_as_handled()
        elif event.index == active_touch:
            active_touch = -1
            knob = JOY_CENTER
            move_changed.emit(Vector2.ZERO)
            get_viewport().set_input_as_handled()
        else:
            pressed_interact = false

    elif event is InputEventScreenDrag and event.index == active_touch:
        _update_joystick(event.position)
        get_viewport().set_input_as_handled()

func _update_joystick(screen_pos: Vector2) -> void:
    var delta := screen_pos - JOY_CENTER
    if delta.length() > JOY_RADIUS:
        delta = delta.normalized() * JOY_RADIUS
    knob = JOY_CENTER + delta
    move_changed.emit(delta / JOY_RADIUS)

func _draw() -> void:
    # Soft translucent controls keep the game visible underneath.
    draw_circle(JOY_CENTER, JOY_RADIUS + 5.0, Color(0.04, 0.03, 0.07, 0.42))
    draw_circle(JOY_CENTER, JOY_RADIUS, Color(0.16, 0.13, 0.24, 0.65))
    draw_circle(knob, KNOB_RADIUS, Color(0.92, 0.82, 0.60, 0.86))
    draw_circle(knob, KNOB_RADIUS - 4.0, Color(0.40, 0.31, 0.47, 0.95))

    var button_color := Color(0.76, 0.54, 0.73, 0.86)
    draw_circle(INTERACT_CENTER, BUTTON_RADIUS + 3.0, Color(0.04, 0.03, 0.07, 0.42))
    draw_circle(INTERACT_CENTER, BUTTON_RADIUS, button_color)
    draw_circle(INTERACT_CENTER, BUTTON_RADIUS - 5.0, Color(0.32, 0.24, 0.40, 0.95))
    draw_string(ThemeDB.fallback_font, INTERACT_CENTER + Vector2(-7, 5), "E", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#fff1c7"))
