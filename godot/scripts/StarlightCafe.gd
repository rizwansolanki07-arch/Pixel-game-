extends Node2D

const TILE := Vector2(64, 32)
const CAFE_RECT := Rect2(76, 48, 250, 128)
const MOVE_SPEED := 95.0

const TABLE_TEX = preload("res://assets/starlight/props/cafe_table.png")
const CHAIR_TEX = preload("res://assets/starlight/props/cafe_chair.png")
const COUNTER_TEX = preload("res://assets/starlight/props/cafe_counter.png")
const PLAYER_RADIUS := 6.0

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
var yui_visual: Node2D
var gathered_today: Dictionary = {}
var ui_font: Font
var recipe_book_open := false
var atmosphere_time := 0.0

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
    yui_visual = get_node("Yui")
    touch_controls = get_node("TouchControls")
    touch_controls.move_changed.connect(_on_touch_move_changed)
    touch_controls.interact_pressed.connect(_on_touch_interact)
    dialogue.finished.connect(_on_dialogue_finished)
    queue_redraw()

func _process(delta: float) -> void:
    _move_player(delta)
    yui_visual.position = player
    yui_visual.set_motion(touch_move if touch_move.length() > 0.05 else Input.get_vector("move_left", "move_right", "move_up", "move_down"), touch_move.length() > 0.05 or Input.get_vector("move_left", "move_right", "move_up", "move_down").length() > 0.05)
    if cooking:
        cooking_time += delta
        if cooking_time >= cooking_duration:
            _finish_cooking()
    _update_interaction()
    atmosphere_time += delta
    message_timer = maxf(0.0, message_timer - delta)
    queue_redraw()

func _move_player(delta: float) -> void:
    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if touch_move.length() > input_dir.length():
        input_dir = touch_move
    if input_dir.length() <= 0.0:
        return

    var velocity := input_dir.normalized() * MOVE_SPEED * delta
    var next_x := player + Vector2(velocity.x, 0.0)
    if _walkable(next_x):
        player = next_x

    var next_y := player + Vector2(0.0, velocity.y)
    if _walkable(next_y):
        player = next_y

    StarlightGameState.player_position = player

func _walkable(pos: Vector2) -> bool:
    if pos.x < CAFE_RECT.position.x + 10.0 or pos.x > CAFE_RECT.end.x - 10.0:
        return false
    if pos.y < CAFE_RECT.position.y + 22.0 or pos.y > CAFE_RECT.end.y - 8.0:
        return false

    var obstacles := [
        Rect2(176, 43, 88, 47),     # counter
        Rect2(110, 76, 78, 66),     # table 1
        Rect2(266, 93, 78, 66),     # table 2
        Rect2(96, 65, 48, 26)       # stove
    ]
    for obstacle in obstacles:
        if obstacle.grow(PLAYER_RADIUS).has_point(pos):
            return false
    return true

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
        elif event.keycode == KEY_I:
            recipe_book_open = not recipe_book_open

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
    _draw_atmosphere(night)
    _draw_shell(night)
    _draw_props(night)
    _draw_gather_spots(night)

    if spirit_visible:
        _draw_spirit()

    _draw_player()
    _draw_ui(night)
    if recipe_book_open:
        _draw_recipe_book()

func _draw_atmosphere(night: bool) -> void:
    if not night:
        return
    # Small, deterministic magical motes instead of a heavy particle system.
    for i in range(14):
        var phase := float(i) * 0.83
        var x := 82.0 + fmod(float(i) * 61.0 + sin(atmosphere_time * 0.7 + phase) * 8.0, 220.0)
        var y := 52.0 + fmod(float(i) * 37.0 + cos(atmosphere_time * 0.45 + phase) * 6.0, 110.0)
        var alpha := 0.25 + 0.12 * sin(atmosphere_time + phase)
        draw_circle(Vector2(x, y), 1.2, Color(0.76, 0.66, 1.0, alpha))

func _draw_recipe_book() -> void:
    draw_rect(Rect2(46, 42, 292, 128), Color(0.035, 0.025, 0.07, 0.97))
    draw_rect(Rect2(48, 44, 288, 124), Color("#73516f"), false, 2.0)
    draw_string(ui_font, Vector2(64, 63), "YUI'S RECIPE BOOK", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#ffe8ae"))
    draw_string(ui_font, Vector2(64, 80), "Moonlight Mushroom Soup", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#f4e5d3"))
    draw_string(ui_font, Vector2(64, 97), "Moon Mushroom       " + str(int(StarlightGameState.inventory.get("moon_mushroom", 0))) + " / 1", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#d9cfe0"))
    draw_string(ui_font, Vector2(64, 110), "Village Herb        " + str(int(StarlightGameState.inventory.get("village_herb", 0))) + " / 2", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#d9cfe0"))
    draw_string(ui_font, Vector2(64, 123), "Milk                " + str(int(StarlightGameState.inventory.get("milk", 0))) + " / 1", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#d9cfe0"))
    draw_string(ui_font, Vector2(64, 136), "Salt                " + str(int(StarlightGameState.inventory.get("salt", 0))) + " / 1", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#d9cfe0"))
    var ready := StarlightGameState.current_recipe == "moon_mushroom_soup"
    draw_string(ui_font, Vector2(64, 153), "Status: " + ("READY TO SERVE" if ready else "COLLECT INGREDIENTS"), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#f2c87e"))
    draw_string(ui_font, Vector2(260, 153), "I / CLOSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#cfc4d8"))

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
    # Premium modular props — intentionally separate from the room shell.
    draw_texture_rect(COUNTER_TEX, Rect2(178, 44, 86, 86), false)
    draw_texture_rect(TABLE_TEX, Rect2(112, 77, 72, 72), false)
    draw_texture_rect(TABLE_TEX, Rect2(268, 94, 72, 72), false)

    # Chairs around the dining tables.
    draw_texture_rect(CHAIR_TEX, Rect2(132, 112, 44, 44), false)
    draw_texture_rect(CHAIR_TEX, Rect2(254, 125, 44, 44), false)
    draw_texture_rect(CHAIR_TEX, Rect2(293, 110, 44, 44), false)

    # Kitchen stove / warm fire.
    draw_rect(Rect2(98, 66, 44, 22), Color("#37313d"))
    draw_rect(Rect2(102, 70, 36, 14), Color("#26222c"))
    draw_circle(Vector2(120, 77), 5.0, Color("#d56b4b") if night else Color("#b35c43"))

    # Window glow becomes magical at night.
    draw_rect(Rect2(274, 60, 30, 28), Color("#6f5a8e") if night else Color("#e9c36a"))
    if night:
        draw_circle(Vector2(289, 74), 18.0, Color(0.55, 0.40, 0.85, 0.12))

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
    # Yui is now rendered by the dedicated 56px presentation node.
    pass

func _draw_ui(night: bool) -> void:
    draw_rect(Rect2(7, 7, 370, 28), Color(0.06, 0.05, 0.10, 0.88))
    var phase_text := "NIGHT" if night else "DAY"
    draw_string(ui_font, Vector2(16, 25), "Day " + str(StarlightGameState.day) + "  •  " + phase_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#f6dfad"))
    draw_string(ui_font, Vector2(150, 25), "WASD Move   E Use   I Recipes   N/D Day-Night   P Save", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#d8cfe4"))

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
