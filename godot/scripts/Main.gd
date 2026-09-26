extends Node2D

var player: CharacterBody2D
var message := ""
var message_timer := 0.0
var dialogue_visible := false
var dialogue_title := ""
var dialogue_text := ""
var dialogue_choices: Array[String] = []
var nearby := ""

func _ready() -> void:
    RenderingServer.set_default_clear_color(Color("#101820"))
    _build_world()
    player = preload("res://scripts/Player.gd").new()
    player.name = "Asha"
    add_child(player)
    player.global_position = GameState.player_position
    queue_redraw()

func _build_world() -> void:
    for item in get_children():
        item.queue_free()
    # collision boundaries
    _add_wall(Vector2(192, 24), Vector2(348, 8))
    _add_wall(Vector2(192, 210), Vector2(348, 8))
    _add_wall(Vector2(12, 117), Vector2(8, 178))
    _add_wall(Vector2(372, 117), Vector2(8, 178))
    _add_wall(Vector2(100, 72), Vector2(70, 32))
    _add_wall(Vector2(280, 72), Vector2(76, 32))
    _add_wall(Vector2(300, 148), Vector2(54, 42))
    _add_wall(Vector2(74, 166), Vector2(56, 28))

func _add_wall(pos: Vector2, size: Vector2) -> void:
    var body := StaticBody2D.new()
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = size
    shape.shape = rect
    body.position = pos
    body.add_child(shape)
    add_child(body)

func _process(delta: float) -> void:
    if player:
        GameState.player_position = player.global_position
        _check_interaction()
    if message_timer > 0:
        message_timer -= delta
        if message_timer <= 0:
            message = ""
            queue_redraw()
    if Input.is_action_just_pressed("interact") and not dialogue_visible:
        _interact()
    elif Input.is_action_just_pressed("interact") and dialogue_visible:
        _advance_dialogue()
    if Input.is_action_just_pressed("save_game"):
        if SaveManager.save_game():
            _show_message("Game saved")
    queue_redraw()

func _check_interaction() -> void:
    nearby = ""
    var targets = {
        "Gopal": Vector2(76, 56),
        "Meera": Vector2(210, 92),
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
            dialogue_title = "Gopal — Innkeeper"
            dialogue_text = "Asha, bazaar se mera ek package gayab ho gaya hai. Kya tum use dhoondhogi?"
            dialogue_choices = ["Haan, main dhoondhungi.", "Abhi nahi."]
            dialogue_visible = true
        elif GameState.quest_state == "found":
            dialogue_title = "Gopal — Innkeeper"
            dialogue_text = "Wahi package! Tumne use dhoondh liya. Shukriya, Asha."
            dialogue_choices = ["Quest complete"]
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
        dialogue_choices = ["Samajh gayi."]
    elif GameState.quest_state == "found":
        GameState.quest_state = "done"
        GameState.world_flags["gopal_helped"] = true
        dialogue_text = "Tumhari madad yaad rahegi."
        dialogue_choices = ["Done"]
    else:
        dialogue_visible = false
        dialogue_choices = []
    queue_redraw()

func _show_message(text: String) -> void:
    message = text
    message_timer = 3.0
    queue_redraw()

func _draw() -> void:
    # Chanderi village pixel-art blockout at the target 384x216 resolution.
    draw_rect(Rect2(0, 0, 384, 216), Color("#83b86b"))
    draw_rect(Rect2(0, 0, 384, 28), Color("#4d7891"))
    draw_rect(Rect2(0, 28, 384, 6), Color("#d7c17a"))
    # paths
    draw_rect(Rect2(145, 34, 38, 176), Color("#c5a26b"))
    draw_rect(Rect2(20, 112, 344, 30), Color("#c5a26b"))
    # buildings
    _building(Rect2(48, 42, 56, 34), "INN", Color("#8f5b3c"))
    _building(Rect2(248, 42, 64, 34), "SETH", Color("#76534b"))
    _building(Rect2(276, 126, 48, 36), "MANDIR", Color("#9b6048"))
    _building(Rect2(48, 150, 54, 30), "HOME", Color("#6e5947"))
    _building(Rect2(184, 148, 52, 34), "GODOWN", Color("#5d5647"))
    # river and ghats
    draw_rect(Rect2(330, 34, 42, 74), Color("#3f8fba"))
    for y in range(42, 106, 12):
        draw_line(Vector2(334, y), Vector2(368, y), Color("#76bdd5"), 1)
    # bazaar stalls/crate
    draw_rect(Rect2(188, 108, 54, 8), Color("#74422e"))
    draw_rect(Rect2(210, 119, 12, 12), Color("#b67b3e"))
    # NPC markers
    _npc(Vector2(76, 56), "G")
    _npc(Vector2(210, 92), "M")
    _npc(Vector2(305, 125), "P")
    # title
    _label(Vector2(12, 8), "CHANDERI QUEST", 12, Color("#fff4d6"))
    _label(Vector2(15, 194), "WASD / Arrows: Move   E / Space: Talk   P: Save", 7, Color("#17221a"))
    if nearby != "" and not dialogue_visible:
        _panel(Rect2(122, 174, 140, 18), "E / TAP  " + nearby)
    if message != "":
        _panel(Rect2(42, 174, 300, 18), message)
    if dialogue_visible:
        _panel(Rect2(22, 145, 340, 55), dialogue_title + "\n" + dialogue_text + "\n[Tap E/Space to continue]")
    _label(Vector2(250, 10), "Quest: " + GameState.quest_state, 7, Color("#fff4d6"))

func _building(rect: Rect2, text: String, c: Color) -> void:
    draw_rect(rect, c)
    draw_rect(Rect2(rect.position + Vector2(5, 7), Vector2(rect.size.x - 10, 8)), Color("#c99655"))
    draw_rect(Rect2(rect.position + Vector2(rect.size.x/2 - 5, rect.size.y - 12), Vector2(10, 12)), Color("#352c2a"))
    _label(rect.position + Vector2(5, 3), text, 7, Color("#fff4d6"))

func _npc(pos: Vector2, letter: String) -> void:
    draw_circle(pos, 7, Color("#f1c7a5"))
    draw_rect(Rect2(pos + Vector2(-7, 6), Vector2(14, 10)), Color("#4c536f"))
    _label(pos + Vector2(-3, -3), letter, 7, Color("#201b22"))

func _panel(rect: Rect2, text: String) -> void:
    draw_rect(rect, Color("#17141b"))
    draw_rect(rect, Color("#e3c978"), false, 1)
    _label(rect.position + Vector2(5, 6), text, 7, Color("#fff4d6"))

func _label(pos: Vector2, text: String, size: int, color: Color) -> void:
    draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
