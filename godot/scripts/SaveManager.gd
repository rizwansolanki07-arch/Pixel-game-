extends Node

const SAVE_PATH := "user://chanderi_quest_save.json"

func save_game() -> bool:
    var data = {
        "map_id": GameState.map_id,
        "player_position": {"x": GameState.player_position.x, "y": GameState.player_position.y},
        "quest_state": GameState.quest_state,
        "world_flags": GameState.world_flags
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
    GameState.map_id = str(parsed.get("map_id", "chanderi_village"))
    var p: Dictionary = parsed.get("player_position", {"x": 72, "y": 120})
    GameState.player_position = Vector2(float(p.get("x", 72)), float(p.get("y", 120)))
    GameState.quest_state = str(parsed.get("quest_state", "not_started"))
    GameState.world_flags = parsed.get("world_flags", {})
    return true
