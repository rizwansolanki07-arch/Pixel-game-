extends Node

const SAVE_PATH := "user://starlight_cafe_save.json"

func save_game() -> bool:
    var data := {
        "day": StarlightGameState.day,
        "phase": StarlightGameState.phase,
        "player_position": {
            "x": StarlightGameState.player_position.x,
            "y": StarlightGameState.player_position.y
        },
        "inventory": StarlightGameState.inventory,
        "unlocked_recipes": StarlightGameState.unlocked_recipes,
        "spirit_progress": StarlightGameState.spirit_progress,
        "cafe_opened": StarlightGameState.cafe_opened
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(data))
    return true

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return false

    StarlightGameState.day = int(parsed.get("day", 1))
    StarlightGameState.phase = String(parsed.get("phase", "day"))
    var p: Dictionary = parsed.get("player_position", {})
    StarlightGameState.player_position = Vector2(
        float(p.get("x", 190.0)),
        float(p.get("y", 138.0))
    )
    StarlightGameState.inventory = parsed.get("inventory", {})
    StarlightGameState.unlocked_recipes = parsed.get("unlocked_recipes", ["moon_mushroom_soup"])
    StarlightGameState.spirit_progress = parsed.get("spirit_progress", {"spirit_001": 0})
    StarlightGameState.cafe_opened = bool(parsed.get("cafe_opened", false))
    return true
