extends SceneTree

const SAVE_PATH := "user://starlight_cafe_save.json"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := root.get_node_or_null("StarlightGameState")
    var director := root.get_node_or_null("StarlightWorldDirector")
    var save_manager := root.get_node_or_null("StarlightSaveManager")

    _check(state != null, "StarlightGameState autoload is available")
    _check(director != null, "StarlightWorldDirector autoload is available")
    _check(save_manager != null, "StarlightSaveManager autoload is available")
    if not failures.is_empty():
        _finish()
        return

    # Legacy save fixture: fields added in later builds are intentionally absent.
    var legacy_data := {
        "day": 4,
        "phase": "night",
        "player_position": {"x": 42.5, "y": 91.25},
        "inventory": {"moon_mint": 3}
    }
    var legacy_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    _check(legacy_file != null, "Can create legacy save fixture")
    if legacy_file == null:
        _finish()
        return
    legacy_file.store_string(JSON.stringify(legacy_data))
    legacy_file.close()

    _check(bool(save_manager.call("load_game")), "Legacy save loads successfully")
    _check(int(state.get("day")) == 4, "Legacy day value is restored")
    _check(String(state.get("phase")) == "night", "Legacy day/night phase is restored")
    var legacy_position: Vector2 = state.get("player_position")
    _check(legacy_position.is_equal_approx(Vector2(42.5, 91.25)), "Legacy player position is restored")
    _check(int(state.get("inventory").get("moon_mint", 0)) == 3, "Legacy inventory is restored")
    _check(state.get("unlocked_recipes").has("moon_mushroom_soup"), "Missing legacy recipe list receives default")
    _check(state.get("spirit_progress").has("spirit_001"), "Missing legacy spirit progress receives default")
    _check(director.get("relationships").has("aoi"), "WorldDirector retains default NPC relationship IDs")

    # New save round-trip: mutate both core state and WorldDirector snapshot data.
    state.set("day", 9)
    state.set("phase", "day")
    state.set("player_position", Vector2(188.0, 121.0))
    state.set("inventory", {"moon_mint": 8, "starberry": 2})
    state.set("unlocked_recipes", ["moon_mushroom_soup", "starlight_tea"])
    state.set("spirit_progress", {"spirit_001": 3, "spirit_002": 1})
    state.set("cafe_opened", true)
    state.set("current_recipe", "starlight_tea")
    state.set("story_flags", {"quest_stage": 2, "language": "EN"})
    director.set("coins", 137)
    var relationships: Dictionary = director.get("relationships").duplicate(true)
    relationships["aoi"] = 4
    director.set("relationships", relationships)

    _check(bool(save_manager.call("save_game")), "New save is written successfully")

    state.set("day", 1)
    state.set("phase", "night")
    state.set("player_position", Vector2.ZERO)
    state.set("inventory", {})
    state.set("unlocked_recipes", ["moon_mushroom_soup"])
    state.set("spirit_progress", {"spirit_001": 0})
    state.set("cafe_opened", false)
    state.set("current_recipe", "")
    state.set("story_flags", {})
    director.set("coins", 80)
    relationships = director.get("relationships").duplicate(true)
    relationships["aoi"] = 0
    director.set("relationships", relationships)

    _check(bool(save_manager.call("load_game")), "New save reloads successfully")
    _check(int(state.get("day")) == 9, "Day survives save/reload")
    _check(String(state.get("phase")) == "day", "Phase survives save/reload")
    var restored_position: Vector2 = state.get("player_position")
    _check(restored_position.is_equal_approx(Vector2(188.0, 121.0)), "Player position survives save/reload")
    _check(int(state.get("inventory").get("moon_mint", 0)) == 8, "Inventory survives save/reload")
    _check(state.get("unlocked_recipes").has("starlight_tea"), "Recipe unlock survives save/reload")
    _check(int(state.get("spirit_progress").get("spirit_002", 0)) == 1, "Spirit progress survives save/reload")
    _check(bool(state.get("cafe_opened")), "Café-open state survives save/reload")
    _check(String(state.get("current_recipe")) == "starlight_tea", "Current recipe survives save/reload")
    _check(int(director.get("coins")) == 137, "WorldDirector coins survive save/reload")
    _check(int(director.get("relationships").get("aoi", 0)) == 4, "NPC relationship survives save/reload")

    var absolute_save_path := ProjectSettings.globalize_path(SAVE_PATH)
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(absolute_save_path)

    _finish()

func _check(condition: bool, description: String) -> void:
    if condition:
        print("PASS: ", description)
    else:
        failures.append(description)
        push_error("FAIL: " + description)

func _finish() -> void:
    if failures.is_empty():
        print("STARLIGHT_SAVE_REGRESSION: PASS")
        quit(0)
    else:
        push_error("STARLIGHT_SAVE_REGRESSION: %d failure(s): %s" % [failures.size(), ", ".join(failures)])
        quit(1)
