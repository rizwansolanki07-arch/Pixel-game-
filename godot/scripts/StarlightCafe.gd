extends Node2D

const TILE := Vector2(64, 32)
const CAFE_RECT := Rect2(76, 48, 250, 128)
const MOVE_SPEED := 95.0

var player := Vector2(190, 138)
var message := "Yui: Café band hai... aaj se phir kholna hai."
var message_timer := 4.0
var spirit_visible := false
var cooking := false
var cooking_time := 0.0
var cooking_duration := 2.5
var interaction_hint := ""
var touch_move := Vector2.ZERO
var dialogue: Node2D
var touch_controls: Node2D
var gathered_today: Dictionary = {}
var ui_font: Font

var spots := {
    "moon_mushroom": Vector2(118, 155),
    "village_herb": Vector2(270, 150),
    "milk": Vector2(286, 92),
    "salt": Vector2(112, 88)
}

func _ready() -> void:
    player = StarlightGameState.player_position
    DayNightManager.phase_changed.connect(_on_phase_changed)
    ui_font = ThemeDB.fallback_font
    dialogue = get_node("Dialogue")
    touch_controls = get_node("TouchControls")
    touch_controls.move_changed.connect(_on_touch_move_changed)
    touch_controls.interact_pressed.connect(_on_touch_interact)
    dialogue.finished.connect(_on_dialogue_finished)
    queue_redraw()

func _process(delta: float) -> void:
    _move_player(delta)
    if cooking:
        cooking_time += delta
        if cooking_time >= cooking_duration:
            _finish_cooking()
    _update_interaction()
    message_timer = maxf(0.0, message_timer - delta)
    queue_redraw()

func _move_player(delta: float) -> void:
    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if touch_move.length() > input_dir.length():
        input_dir = touch_move
    if input_dir.length() > 0.0:
        player += input_dir.normalized() * MOVE_SPEED * delta
        player.x = clampf(player.x, CAFE_RECT.position.x + 10.0, CAFE_RECT.end.x - 10.0)
        player.y = clampf(player.y, CAFE_RECT.position.y + 22.0, CAFE_RECT.end.y - 8.0)
        StarlightGameState.player_position = player

func _input(event: InputEvent) -> void:
    if dialogue != null and dialogue.active:
        return
    if event.is_action_pressed("interact"):
        _interact()
    if event.is_action_pressed("save_game"):
        _save()
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_N:
            DayNightManager.set_phase("night")
        elif event.keycode == KEY_D:
            DayNightManager.set_phase("day")
        elif event.keycode == KEY_C:
            _cook()

func _update_interaction() -> void:
    interaction_hint = ""
    var target := _nearest_target()
    if target == "":
        return
    if target == "spirit":
        interaction_hint = "E  Talk / Serve"
    elif target == "counter":
        interaction_hint = "E  Cook"
    else:
        interaction_hint = "E  Gather " + target.replace("_", " ")

func _nearest_target() -> String:
    var best := ""
    var best_dist := 999.0
    for id in spots:
        var d := player.distance_to(spots[id])
        if d < 24.0 and d < best_dist:
            best = id
            best_dist = d
    var counter := Vector2(222, 78)
    if player.distance_to(counter) < 28.0 and player.distance_to(counter) < best_dist:
        return "counter"
    if spirit_visible:
        var spirit_pos := Vector2(235, 116)
        if player.distance_to(spirit_pos) < 30.0 and player.distance_to(spirit_pos) < best_dist:
            return "spirit"
    return best

func _interact() -> void:
    var target := _nearest_target()
    if target == "":
        message = "Walk near something to interact."
        message_timer = 2.0
        return
    if target == "counter":
        _cook()
        return
    if target == "spirit":
        _serve_spirit()
        return

    var amount := 2 if target == "village_herb" else 1
    var key := str(StarlightGameState.day) + "_" + target
    if gathered_today.has(key):
        message = "Yui: Is jagah se aaj itna hi mila."
    else:
        StarlightGameState.add_item(target, amount)
        gathered_today[key] = true
        message = "Collected: " + target.replace("_", " ") + " x" + str(amount)
    message_timer = 2.0

func _cook() -> void:
    if cooking:
        message = "Yui: Soup abhi cook ho rahi hai..."
        message_timer = 1.5
        return
    var recipe := {
        "id": "moon_mushroom_soup",
        "name": "Moonlight Mushroom Soup",
        "ingredients": [
            {"id": "moon_mushroom", "amount": 1},
            {"id": "village_herb", "amount": 2},
            {"id": "milk", "amount": 1},
            {"id": "salt", "amount": 1}
        ]
    }
    if StarlightGameState.can_cook(recipe):
        StarlightGameState.current_recipe = ""
        cooking = true
        cooking_time = 0.0
        message = "Yui: Soup simmer ho rahi hai..."
        message_timer = 1.8
    else:
        message = "Yui: Ingredients kam hain."
        message_timer = 2.5

func _serve_spirit() -> void:
    if not spirit_visible:
        return
    var progress := int(StarlightGameState.spirit_progress.get("spirit_001", 0))
    if cooking:
        return
    if StarlightGameState.current_recipe == "moon_mushroom_soup":
        StarlightGameState.current_recipe = ""
        progress += 1
        StarlightGameState.spirit_progress["spirit_001"] = progress
        dialogue.begin("Aoi", [
            "...yeh khushboo mujhe yaad hai.",
            "Tumhare café mein kuch ghar jaisa lagta hai.",
            "Aaj meri ek bhooli hui yaad wapas aayi."
        ])
        return
    if progress >= 1:
        dialogue.begin("Aoi", ["Kal raat phir milungi, Yui."])
    else:
        dialogue.begin("Aoi", [
            "Mujhe Moonlight Mushroom Soup chahiye...",
            "Uski khushboo mujhe ek purani raat yaad dilati hai."
        ])

func _finish_cooking() -> void:
    cooking = false
    cooking_time = 0.0
    var recipe := {
        "ingredients": [
            {"id": "moon_mushroom", "amount": 1},
            {"id": "village_herb", "amount": 2},
            {"id": "milk", "amount": 1},
            {"id": "salt", "amount": 1}
        ]
    }
    if StarlightGameState.cook(recipe):
        StarlightGameState.current_recipe = "moon_mushroom_soup"
        message = "Moonlight Mushroom Soup ready!"
        message_timer = 3.0
    else:
        message = "Yui: Ingredients change ho gaye. Cooking fail."
        message_timer = 2.5

func _on_touch_move_changed(direction: Vector2) -> void:
    touch_move = direction
    StarlightGameState.touch_move = direction

func _on_touch_interact() -> void:
    if dialogue != null and dialogue.active:
        dialogue.advance()
    else:
        _interact()

func _on_dialogue_finished() -> void:
    message = "Aoi ki story progress: " + str(StarlightGameState.spirit_progress.get("spirit_001", 0))
    message_timer = 2.5

func _on_phase_changed(phase: String) -> void:
    spirit_visible = phase == "night"
    if phase == "night":
        message = "Night  " + str(StarlightGameState.day) + ": Aoi café mein aa gayi."
    else:
        gathered_today.clear()
        message = "Morning: gaon se ingredients collect karo."
    message_timer = 3.5

func _save() -> void:
    if StarlightSaveManager.save_game():
        message = "Game saved."
    else:
        message = "Save failed."
    message_timer = 2.0

func _draw() -> void:
    var night := StarlightGameState.phase == "night"
    var bg := Color("#17152a") if night else Color("#c9a66b")
    draw_rect(Rect2(0, 0, 384, 216), bg)

    _draw_floor(night)
    _draw_shell(night)
    _draw_props(night)
    _draw_gather_spots(night)

    if spirit_visible:
        _draw_spirit()

    _draw_player()
    _draw_ui(night)

func _draw_floor(night: bool) -> void:
    var floor_color := Color("#493e58") if night else Color("#355246")
    for y in range(-3, 8):
        for x in range(-3, 10):
            var p := Vector2(190, 110) + Vector2((x - y) * 32.0, (x + y) * 16.0)
            _diamond(p, 32.0, 16.0, floor_color)

func _draw_shell(night: bool) -> void:
    var wall := Color("#3c3150") if night else Color("#6e4a5f")
    draw_rect(CAFE_RECT, wall, false, 7.0)
    draw_line(Vector2(92, 72), Vector2(308, 72), Color("#b77c52") if not night else Color("#6d5b8e"), 5.0)
    draw_line(Vector2(92, 164), Vector2(308, 164), Color("#5b3e3f"), 5.0)

func _draw_props(night: bool) -> void:
    # Counter
    draw_rect(Rect2(198, 67, 58, 20), Color("#8f5f3e"))
    draw_rect(Rect2(202, 63, 50, 7), Color("#d09a54"))
    # Tables and chairs
    for p in [Vector2(150, 105), Vector2(285, 124)]:
        _draw_table(p)
    # Stove
    draw_rect(Rect2(110, 68, 38, 18), Color("#37313d"))
    draw_circle(Vector2(129, 77), 5.0, Color("#d56b4b") if night else Color("#b35c43"))
    # Window glow
    draw_rect(Rect2(270, 74, 28, 24), Color("#6f5a8e") if night else Color("#e9c36a"))
    if night:
        draw_circle(Vector2(284, 86), 16.0, Color(0.55, 0.40, 0.85, 0.12))

func _draw_table(p: Vector2) -> void:
    _diamond(p, 25.0, 13.0, Color("#b77c35"))
    draw_line(p + Vector2(-22, 3), p + Vector2(-15, 25), Color("#3d3442"), 5.0)
    draw_line(p + Vector2(20, 3), p + Vector2(14, 25), Color("#3d3442"), 5.0)
    draw_line(p + Vector2(0, 7), p + Vector2(-2, 27), Color("#3d3442"), 5.0)

func _draw_gather_spots(night: bool) -> void:
    for id in spots:
        var p: Vector2 = spots[id]
        var c := Color("#b8e37d") if not night else Color("#a18bd1")
        draw_circle(p, 6.0, c)
        draw_circle(p, 3.0, Color("#3a2d42"))
        draw_string(ui_font, p + Vector2(-18, -9), id.replace("_", " "), HORIZONTAL_ALIGNMENT_LEFT, 90, 8, Color("#f2e7c9"))

func _draw_spirit() -> void:
    var p := Vector2(235, 116)
    draw_circle(p, 13.0, Color(0.55, 0.42, 0.90, 0.32))
    draw_circle(p + Vector2(0, -3), 7.0, Color("#d8c9ff"))
    draw_circle(p + Vector2(-3, -4), 1.5, Color("#30273e"))
    draw_circle(p + Vector2(3, -4), 1.5, Color("#30273e"))
    draw_line(p + Vector2(-5, 5), p + Vector2(5, 5), Color("#8d72c4"), 2.0)
    draw_string(ui_font, p + Vector2(-10, -18), "Aoi", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#f1ddff"))

func _draw_player() -> void:
    var p := player
    draw_ellipse(p + Vector2(0, 18), Vector2(8, 4), Color(0, 0, 0, 0.25))
    draw_circle(p, 7.0, Color("#f2c19b"))
    draw_arc(p, 7.0, PI, TAU, 8, Color("#2b2030"), 5.0)
    draw_rect(Rect2(p + Vector2(-6, 6), Vector2(12, 17)), Color("#d08b56"))
    draw_line(p + Vector2(-2, 23), p + Vector2(-5, 31), Color("#332936"), 3.0)
    draw_line(p + Vector2(2, 23), p + Vector2(6, 31), Color("#332936"), 3.0)

func _draw_ui(night: bool) -> void:
    draw_rect(Rect2(7, 7, 370, 28), Color(0.06, 0.05, 0.10, 0.88))
    var phase_text := "NIGHT" if night else "DAY"
    draw_string(ui_font, Vector2(16, 25), "Day " + str(StarlightGameState.day) + "  •  " + phase_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#f6dfad"))
    draw_string(ui_font, Vector2(150, 25), "WASD Move   E Interact   N/D Day-Night   P Save", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#d8cfe4"))

    var inv := "Soup: " + ("COOKING" if cooking else ("READY" if StarlightGameState.current_recipe == "moon_mushroom_soup" else "—"))
    inv += "   Herbs " + str(int(StarlightGameState.inventory.get("village_herb", 0)))
    inv += "   Milk " + str(int(StarlightGameState.inventory.get("milk", 0)))
    inv += "   Mushroom " + str(int(StarlightGameState.inventory.get("moon_mushroom", 0)))
    inv += "   Salt " + str(int(StarlightGameState.inventory.get("salt", 0)))
    draw_rect(Rect2(7, 184, 370, 24), Color(0.06, 0.05, 0.10, 0.88))
    draw_string(ui_font, Vector2(14, 200), inv, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#e7d8c2"))

    if interaction_hint != "":
        draw_rect(Rect2(115, 164, 154, 17), Color(0.08, 0.06, 0.13, 0.9))
        draw_string(ui_font, Vector2(124, 176), interaction_hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#fff0bd"))
    if cooking:
        draw_rect(Rect2(110, 110, 164, 7), Color("#2e2536"))
        draw_rect(Rect2(112, 112, 160 * clampf(cooking_time / cooking_duration, 0.0, 1.0), 3), Color("#e0a45e"))

    if message_timer > 0.0:
        draw_rect(Rect2(52, 142, 280, 18), Color(0.07, 0.05, 0.10, 0.92))
        draw_string(ui_font, Vector2(60, 155), message, HORIZONTAL_ALIGNMENT_LEFT, 265, 8, Color("#f2e6d0"))

func _diamond(center: Vector2, half_w: float, half_h: float, color: Color) -> void:
    var pts := PackedVector2Array([
        center + Vector2(0, -half_h),
        center + Vector2(half_w, 0),
        center + Vector2(0, half_h),
        center + Vector2(-half_w, 0)
    ])
    draw_colored_polygon(pts, color)

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var points := PackedVector2Array()
    for i in range(24):
        var a := TAU * float(i) / 24.0
        points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
    draw_colored_polygon(points, color)
