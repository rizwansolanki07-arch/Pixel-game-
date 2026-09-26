extends Node2D

const W := 384.0
const H := 216.0

var player: CharacterBody2D
var message := ""
var message_timer := 0.0
var dialogue_visible := false
var dialogue_title := ""
var dialogue_text := ""
var nearby := ""
var move_touch_id := -1
var interact_touch_id := -1
var save_touch_id := -1
var last_touch := Vector2.ZERO

func _ready() -> void:
    RenderingServer.set_default_clear_color(Color("#101820"))
    print("CHANDERI_RUNTIME_OK: Main._ready entered")
    _build_world()
    _add_premium_backdrop()
    player = preload("res://scripts/Player.gd").new()
    player.name = "Asha"
    add_child(player)
    player.global_position = GameState.player_position
    queue_redraw()

func _add_premium_backdrop() -> void:
    # Use the repository's premium/modern art layer behind the authored village.
    # It is optional at runtime so a missing imported texture never blocks gameplay.
    var tex: Texture2D = load("res://src/art/assets/modern/bg_base.png")
    if tex == null:
        return
    var backdrop := Sprite2D.new()
    backdrop.texture = tex
    backdrop.centered = true
    backdrop.position = Vector2(W * 0.5, H * 0.5)
    backdrop.z_index = -20
    backdrop.modulate = Color(1, 1, 1, 0.42)
    var tw := float(tex.get_width())
    var th := float(tex.get_height())
    if tw > 0.0 and th > 0.0:
        var scale_factor := min(W / tw, H / th)
        backdrop.scale = Vector2(scale_factor, scale_factor)
    add_child(backdrop)

func _build_world() -> void:
    for item in get_children():
        if item != player:
            item.queue_free()
    _add_wall(Vector2(192, 31), Vector2(348, 8))
    _add_wall(Vector2(192, 208), Vector2(348, 8))
    _add_wall(Vector2(12, 120), Vector2(8, 168))
    _add_wall(Vector2(372, 120), Vector2(8, 168))
    _add_wall(Vector2(76, 67), Vector2(58, 31))
    _add_wall(Vector2(278, 67), Vector2(68, 31))
    _add_wall(Vector2(301, 150), Vector2(54, 43))
    _add_wall(Vector2(75, 166), Vector2(58, 31))
    _add_wall(Vector2(210, 166), Vector2(55, 34))

func _add_wall(pos: Vector2, size: Vector2) -> void:
    var body := StaticBody2D.new()
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = size
    shape.shape = rect
    body.position = pos
    body.add_child(shape)
    add_child(body)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var p: Vector2 = event.position
        if event.pressed:
            if Rect2(10, 138, 72, 68).has_point(p):
                move_touch_id = event.index
                _set_touch_move(p)
            elif Rect2(305, 148, 68, 60).has_point(p):
                interact_touch_id = event.index
                GameState.touch_interact = true
            elif Rect2(267, 148, 36, 42).has_point(p):
                save_touch_id = event.index
                GameState.touch_save = true
        else:
            if event.index == move_touch_id:
                move_touch_id = -1
                GameState.touch_move = Vector2.ZERO
            if event.index == interact_touch_id:
                interact_touch_id = -1
                GameState.touch_interact = false
            if event.index == save_touch_id:
                save_touch_id = -1
                GameState.touch_save = false
    elif event is InputEventScreenDrag:
        if event.index == move_touch_id:
            _set_touch_move(event.position)

func _set_touch_move(p: Vector2) -> void:
    var center := Vector2(44, 172)
    var delta := p - center
    GameState.touch_move = delta.limit_length(26.0) / 26.0
    last_touch = p

func _process(delta: float) -> void:
    if player:
        GameState.player_position = player.global_position
        _check_interaction()

    if GameState.touch_interact:
        GameState.touch_interact = false
        if dialogue_visible:
            _advance_dialogue()
        else:
            _interact()

    if GameState.touch_save:
        GameState.touch_save = false
        if SaveManager.save_game():
            _show_message("Game saved")

    if message_timer > 0:
        message_timer -= delta
        if message_timer <= 0:
            message = ""
            queue_redraw()

    if Input.is_action_just_pressed("interact"):
        if dialogue_visible:
            _advance_dialogue()
        else:
            _interact()

    if Input.is_action_just_pressed("save_game"):
        if SaveManager.save_game():
            _show_message("Game saved")

    queue_redraw()

func _check_interaction() -> void:
    nearby = ""
    var targets = {
        "Gopal": Vector2(76, 56),
        "Meera": Vector2(210, 91),
        "Pandit Dev": Vector2(305, 125),
        "Bazaar Crate": Vector2(215, 128)
    }
    for name in targets:
        if player.global_position.distance_to(targets[name]) < 28:
            nearby = name
            break

func _interact() -> void:
    if nearby == "Gopal":
        if GameState.quest_state == "not_started":
            dialogue_title = "Gopal • Innkeeper"
            dialogue_text = "Asha, bazaar se mera ek package gayab ho gaya hai. Kya tum use dhoondhogi?"
            dialogue_visible = true
        elif GameState.quest_state == "found":
            dialogue_title = "Gopal • Innkeeper"
            dialogue_text = "Wahi package! Tumne use dhoondh liya. Shukriya, Asha."
            dialogue_visible = true
        else:
            _show_message("Gopal: Bazaar mein package check karo.")
    elif nearby == "Bazaar Crate":
        if GameState.quest_state == "accepted":
            GameState.quest_state = "found"
            _show_message("Package mil gaya! Innkeeper ke paas wapas jao.")
        else:
            _show_message("Purana bazaar crate.")
    elif nearby == "Meera":
        _show_message("Meera: Bazaar mein aaj kaafi kaam hai.")
    elif nearby == "Pandit Dev":
        _show_message("Pandit Dev: Mandir shaant rakho, beta.")

func _advance_dialogue() -> void:
    if GameState.quest_state == "not_started" and dialogue_title.begins_with("Gopal"):
        GameState.quest_state = "accepted"
        dialogue_text = "Bahut achha. Bazaar ke crate ke paas dekho."
    elif GameState.quest_state == "found" and dialogue_title.begins_with("Gopal"):
        GameState.quest_state = "done"
        GameState.world_flags["gopal_helped"] = true
        dialogue_text = "Tumhari madad yaad rahegi."
    else:
        dialogue_visible = false
    if GameState.quest_state == "done":
        dialogue_visible = false
    queue_redraw()

func _show_message(text: String) -> void:
    message = text
    message_timer = 3.0
    queue_redraw()

func _draw() -> void:
    # Base ground.
    draw_rect(Rect2(0, 0, W, H), Color("#78ad63"))

    # Subtle grass pixel pattern.
    for y in range(36, 210, 12):
        for x in range(8, 376, 16):
            if (x + y) % 32 == 0:
                draw_rect(Rect2(x, y, 2, 2), Color("#6a9d58"))

    # Header.
    draw_rect(Rect2(0, 0, W, 28), Color("#315b70"))
    draw_rect(Rect2(0, 27, W, 3), Color("#d5b96a"))
    _label(Vector2(12, 9), "CHANDERI QUEST", 12, Color("#fff2c9"))
    _label(Vector2(274, 9), "QUEST", 7, Color("#dcecf1"))
    _label(Vector2(311, 9), GameState.quest_state.to_upper(), 7, Color("#ffe6a5"))

    # Main roads with edge pixels.
    draw_rect(Rect2(144, 30, 40, 178), Color("#c7a16a"))
    draw_rect(Rect2(18, 112, 348, 31), Color("#c7a16a"))
    draw_rect(Rect2(144, 30, 2, 178), Color("#b18b58"))
    draw_rect(Rect2(182, 30, 2, 178), Color("#b18b58"))
    draw_rect(Rect2(18, 112, 348, 2), Color("#b18b58"))
    draw_rect(Rect2(18, 141, 348, 2), Color("#b18b58"))

    # River.
    draw_rect(Rect2(331, 30, 41, 82), Color("#2d86b2"))
    for y in range(38, 106, 10):
        draw_line(Vector2(334, y), Vector2(368, y), Color("#67b8d2"), 1)
    draw_rect(Rect2(326, 106, 46, 8), Color("#a98259"))
    draw_rect(Rect2(326, 114, 46, 5), Color("#806246"))

    # Buildings.
    _building(Rect2(48, 43, 56, 33), "INN", Color("#92553c"), Color("#d39b57"))
    _building(Rect2(248, 43, 64, 33), "SETH", Color("#76534b"), Color("#d09b57"))
    _building(Rect2(276, 126, 48, 37), "MANDIR", Color("#a65d43"), Color("#e0a85f"))
    _building(Rect2(48, 151, 55, 30), "HOME", Color("#765a45"), Color("#c99555"))
    _building(Rect2(184, 149, 54, 34), "GODOWN", Color("#5d594a"), Color("#bd955d"))

    # Bazaar stall and package crate.
    draw_rect(Rect2(188, 106, 54, 7), Color("#673c2d"))
    draw_rect(Rect2(188, 101, 54, 6), Color("#d5a25b"))
    draw_rect(Rect2(210, 119, 12, 12), Color("#a96e35"))
    draw_rect(Rect2(212, 121, 8, 8), Color("#c58a45"))

    # Trees / greenery.
    _tree(Vector2(26, 51))
    _tree(Vector2(126, 49))
    _tree(Vector2(356, 45))
    _tree(Vector2(24, 184))
    _tree(Vector2(354, 187))

    # NPCs.
    _npc(Vector2(76, 56), "G", Color("#45526d"), Color("#b97846"))
    _npc(Vector2(210, 91), "M", Color("#5b496b"), Color("#d28b4f"))
    _npc(Vector2(305, 125), "P", Color("#4e5969"), Color("#d6a55c"))

    # Touch controls, intentionally semi-transparent and unobtrusive.
    _joystick()
    _touch_button(Rect2(267, 158, 34, 26), "SAVE", Color("#3b6b78"))
    _touch_button(Rect2(311, 151, 57, 39), "TALK", Color("#6b4b62"))

    # Desktop hint.
    _label(Vector2(12, 205), "WASD / Arrows  •  E = Talk  •  P = Save", 6, Color("#eef1d9"))

    if nearby != "" and not dialogue_visible:
        _panel(Rect2(112, 174, 154, 18), "E / TALK  " + nearby)

    if message != "":
        _panel(Rect2(36, 174, 278, 18), message)

    if dialogue_visible:
        _dialogue_panel()

func _building(rect: Rect2, text: String, wall: Color, roof: Color) -> void:
    # Roof shadow and wall.
    draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size), Color("#49352e"))
    draw_rect(rect, wall)
    draw_rect(Rect2(rect.position + Vector2(-2, -4), Vector2(rect.size.x + 4, 7)), roof)
    draw_rect(Rect2(rect.position + Vector2(5, 9), Vector2(rect.size.x - 10, 6)), Color("#e0ad68"))
    draw_rect(Rect2(rect.position + Vector2(rect.size.x / 2 - 5, rect.size.y - 11), Vector2(10, 11)), Color("#352b2b"))
    _label(rect.position + Vector2(5, 4), text, 7, Color("#fff2d0"))

func _tree(pos: Vector2) -> void:
    draw_rect(Rect2(pos + Vector2(-2, 5), Vector2(5, 9)), Color("#69472e"))
    draw_rect(Rect2(pos + Vector2(-8, -4), Vector2(16, 11)), Color("#3e7547"))
    draw_rect(Rect2(pos + Vector2(-5, -9), Vector2(11, 9)), Color("#4e8b4e"))
    draw_rect(Rect2(pos + Vector2(-2, -11), Vector2(5, 5)), Color("#67a857"))

func _npc(pos: Vector2, letter: String, clothes: Color, accent: Color) -> void:
    draw_rect(Rect2(pos + Vector2(-4, 11), Vector2(8, 4)), Color("#5b4538"))
    draw_circle(pos + Vector2(0, -1), 6, Color("#f0c5a2"))
    draw_rect(Rect2(pos + Vector2(-7, 5), Vector2(14, 9)), clothes)
    draw_rect(Rect2(pos + Vector2(-7, 5), Vector2(14, 2)), accent)
    _label(pos + Vector2(-3, -4), letter, 6, Color("#241c22"))

func _joystick() -> void:
    draw_circle(Vector2(44, 172), 26, Color(0.05, 0.08, 0.10, 0.42))
    draw_circle(Vector2(44, 172), 17, Color(0.16, 0.22, 0.24, 0.62))
    draw_circle(Vector2(44, 172) + GameState.touch_move * 10.0, 9, Color("#d7b968"))
    _label(Vector2(29, 202), "MOVE", 6, Color("#fff2c9"))

func _touch_button(rect: Rect2, text: String, color: Color) -> void:
    draw_rect(rect, Color(0, 0, 0, 0.30))
    draw_rect(rect, color)
    draw_rect(rect, Color("#e3c978"), false, 1)
    _label(rect.position + Vector2(6, 16), text, 6, Color("#fff2c9"))

func _dialogue_panel() -> void:
    draw_rect(Rect2(14, 130, 356, 76), Color(0.06, 0.06, 0.08, 0.96))
    draw_rect(Rect2(14, 130, 356, 76), Color("#d9bb67"), false, 2)
    _label(Vector2(24, 143), dialogue_title, 8, Color("#ffd978"))
    _label(Vector2(24, 158), dialogue_text, 7, Color("#fff4d6"))
    _label(Vector2(24, 181), "TAP TALK / E to continue", 6, Color("#bcd0d4"))

func _panel(rect: Rect2, text: String) -> void:
    draw_rect(rect, Color(0.07, 0.06, 0.08, 0.94))
    draw_rect(rect, Color("#e3c978"), false, 1)
    _label(rect.position + Vector2(5, 12), text, 6, Color("#fff4d6"))

func _label(pos: Vector2, text: String, size: int, color: Color) -> void:
    draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
