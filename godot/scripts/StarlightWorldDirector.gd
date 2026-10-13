extends Node

## Persistent content systems for Starlight Café.
## Keeps story, NPC relationships, farm plots, furniture ownership and village
## progression separate from the presentation/gameplay controller.

signal relationship_changed(npc_id: String, value: int)
signal crop_changed(plot_id: String, crop_id: String, stage: int)
signal quest_changed(quest_id: String, status: String)
signal coins_changed(total: int)

const STARTING_COINS := 80
const NPCS := {
    "yui": {"name": "Yui", "role": "Café keeper", "home": "cafe", "schedule": {"day": "cafe", "evening": "cafe", "night": "cafe"}},
    "mina": {"name": "Mina", "role": "Market herbalist", "home": "market", "schedule": {"day": "market", "evening": "market", "night": "home"}},
    "bram": {"name": "Bram", "role": "Village gardener", "home": "garden", "schedule": {"day": "garden", "evening": "well", "night": "home"}},
    "aoi": {"name": "Aoi", "role": "Memory spirit", "home": "cafe", "schedule": {"day": "spirit_realm", "evening": "cafe", "night": "cafe"}},
    "ren": {"name": "Ren", "role": "Lost spirit", "home": "shrine", "schedule": {"day": "spirit_realm", "evening": "shrine", "night": "cafe"}},
    "hana": {"name": "Hana", "role": "Spirit of the old garden", "home": "orchard", "schedule": {"day": "orchard", "evening": "orchard", "night": "cafe"}}
}
const CROPS := {
    "moon_mint": {"name": "Moon Mint", "seed_cost": 8, "sell_price": 14, "days_to_grow": 2, "yield": 2, "season": "all"},
    "starberry": {"name": "Starberry", "seed_cost": 14, "sell_price": 25, "days_to_grow": 3, "yield": 2, "season": "spring"},
    "honeyroot": {"name": "Honeyroot", "seed_cost": 10, "sell_price": 18, "days_to_grow": 2, "yield": 1, "season": "all"},
    "dawn_grain": {"name": "Dawn Grain", "seed_cost": 6, "sell_price": 11, "days_to_grow": 3, "yield": 3, "season": "autumn"}
}
const FURNITURE := {
    "oak_cafe_table": {"name": "Oak Café Table", "cost": 45, "category": "table", "footprint": [2, 1]},
    "cushioned_stool": {"name": "Cushioned Stool", "cost": 22, "category": "seat", "footprint": [1, 1]},
    "moon_lantern": {"name": "Moon Lantern", "cost": 35, "category": "light", "footprint": [1, 1]},
    "herb_planter": {"name": "Herb Planter", "cost": 28, "category": "decor", "footprint": [1, 1]},
    "memory_shelf": {"name": "Memory Shelf", "cost": 60, "category": "storage", "footprint": [2, 1]},
    "starry_rug": {"name": "Starry Rug", "cost": 38, "category": "decor", "footprint": [2, 1]}
}
const QUESTS := {
    "q_reopen_cafe": {"chapter": 1, "title": "A Light in the Window", "description": "Gather herbs, reopen Papa's café and prepare the first meal.", "reward_coins": 30},
    "q_aoi_memory": {"chapter": 1, "title": "A Bowl Full of Home", "description": "Serve Aoi Moonlight Mushroom Soup and listen to her memory.", "reward_coins": 45},
    "q_village_garden": {"chapter": 2, "title": "Seeds for Tomorrow", "description": "Plant, water and harvest your first café garden crop.", "reward_coins": 35},
    "q_hana_garden": {"chapter": 2, "title": "The Garden That Remembers", "description": "Meet Hana after dark and restore the forgotten herb garden.", "reward_coins": 55},
    "q_ren_dawn": {"chapter": 2, "title": "A Morning Never Forgotten", "description": "Prepare Dawn Porridge and help Ren recover a memory of home.", "reward_coins": 50}
}

var coins: int = STARTING_COINS
var relationships: Dictionary = {"yui": 0, "mina": 0, "bram": 0, "aoi": 0, "ren": 0, "hana": 0}
var farm_plots: Dictionary = {}
var owned_furniture: Array[String] = ["oak_cafe_table", "cushioned_stool"]
var placed_furniture: Array[Dictionary] = []
var quest_status: Dictionary = {"q_reopen_cafe": "active"}
var active_quest: String = "q_reopen_cafe"
var story_chapter: int = 1
var story_flags: Dictionary = {"father_letter_found": false, "garden_restored": false, "all_spirit_memories": false}
var day_part: String = "day"
var season: String = "spring"

func _ready() -> void:
    if not DayNightManager.phase_changed.is_connected(_on_phase_changed):
        DayNightManager.phase_changed.connect(_on_phase_changed)
    sync_phase(StarlightGameState.phase)

func _on_phase_changed(next_phase: String) -> void:
    sync_phase(next_phase)
    if next_phase == "day":
        advance_farm_day()

func npc_location(npc_id: String, part: String = "") -> String:
    if not NPCS.has(npc_id):
        return ""
    var schedule: Dictionary = NPCS[npc_id].get("schedule", {})
    var requested_part := part if part != "" else day_part
    return String(schedule.get(requested_part, NPCS[npc_id].get("home", "")))

func talk_to_npc(npc_id: String) -> int:
    if not relationships.has(npc_id):
        return 0
    var next_value := mini(100, int(relationships[npc_id]) + 1)
    relationships[npc_id] = next_value
    relationship_changed.emit(npc_id, next_value)
    return next_value

func add_coins(amount: int) -> void:
    coins = maxi(0, coins + amount)
    coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
    if amount < 0 or coins < amount:
        return false
    coins -= amount
    coins_changed.emit(coins)
    return true

func plant_crop(plot_id: String, crop_id: String) -> bool:
    if not CROPS.has(crop_id) or farm_plots.has(plot_id):
        return false
    if not spend_coins(int(CROPS[crop_id].seed_cost)):
        return false
    farm_plots[plot_id] = {"crop_id": crop_id, "stage": 0, "watered": false, "planted_day": StarlightGameState.day}
    crop_changed.emit(plot_id, crop_id, 0)
    return true

func water_crop(plot_id: String) -> bool:
    if not farm_plots.has(plot_id):
        return false
    var plot: Dictionary = farm_plots[plot_id]
    plot["watered"] = true
    farm_plots[plot_id] = plot
    return true

func advance_farm_day() -> void:
    for plot_id in farm_plots.keys():
        var plot: Dictionary = farm_plots[plot_id]
        if bool(plot.get("watered", false)):
            var crop_id := String(plot.get("crop_id", ""))
            var max_stage := int(CROPS.get(crop_id, {}).get("days_to_grow", 2))
            var stage := mini(max_stage, int(plot.get("stage", 0)) + 1)
            plot["stage"] = stage
            plot["watered"] = false
            farm_plots[plot_id] = plot
            crop_changed.emit(String(plot_id), crop_id, stage)

func harvest_crop(plot_id: String) -> Dictionary:
    if not farm_plots.has(plot_id):
        return {}
    var plot: Dictionary = farm_plots[plot_id]
    var crop_id := String(plot.get("crop_id", ""))
    if not CROPS.has(crop_id) or int(plot.get("stage", 0)) < int(CROPS[crop_id].days_to_grow):
        return {}
    var crop: Dictionary = CROPS[crop_id]
    farm_plots.erase(plot_id)
    StarlightGameState.add_item(crop_id, int(crop.get("yield", 1)))
    crop_changed.emit(plot_id, crop_id, -1)
    return {"crop_id": crop_id, "amount": int(crop.get("yield", 1))}

func buy_furniture(furniture_id: String) -> bool:
    if not FURNITURE.has(furniture_id) or furniture_id in owned_furniture:
        return false
    if not spend_coins(int(FURNITURE[furniture_id].cost)):
        return false
    owned_furniture.append(furniture_id)
    return true

func place_furniture(furniture_id: String, world_position: Vector2) -> bool:
    if not furniture_id in owned_furniture or not FURNITURE.has(furniture_id):
        return false
    var item: Dictionary = FURNITURE[furniture_id]
    var footprint: Array = item.get("footprint", [1, 1])
    var size := Vector2(float(footprint[0]) * 16.0, float(footprint[1]) * 8.0)
    var candidate := Rect2(world_position - size * 0.5, size)
    for placed in placed_furniture:
        var stored_position: Array = placed.get("position", [0.0, 0.0])
        var existing_position := Vector2(float(stored_position[0]), float(stored_position[1]))
        var existing_id := String(placed.get("id", ""))
        var existing_item: Dictionary = FURNITURE.get(existing_id, {})
        var existing_footprint: Array = existing_item.get("footprint", [1, 1])
        var existing_size := Vector2(float(existing_footprint[0]) * 16.0, float(existing_footprint[1]) * 8.0)
        var existing_rect := Rect2(existing_position - existing_size * 0.5, existing_size)
        if candidate.intersects(existing_rect):
            return false
    placed_furniture.append({"id": furniture_id, "position": [world_position.x, world_position.y]})
    return true

func complete_quest(quest_id: String) -> bool:
    if not QUESTS.has(quest_id) or String(quest_status.get(quest_id, "locked")) == "complete":
        return false
    quest_status[quest_id] = "complete"
    add_coins(int(QUESTS[quest_id].get("reward_coins", 0)))
    quest_changed.emit(quest_id, "complete")
    _select_next_quest()
    return true

func unlock_quest(quest_id: String) -> void:
    if QUESTS.has(quest_id) and not quest_status.has(quest_id):
        quest_status[quest_id] = "active"
        if active_quest == "":
            active_quest = quest_id
        quest_changed.emit(quest_id, "active")

func sync_phase(phase: String) -> void:
    day_part = "night" if phase == "night" else "day"

func get_active_quest() -> Dictionary:
    return QUESTS.get(active_quest, {})

func _select_next_quest() -> void:
    active_quest = ""
    for quest_id in QUESTS:
        if String(quest_status.get(quest_id, "locked")) == "active":
            active_quest = quest_id
            return

func get_snapshot() -> Dictionary:
    return {
        "coins": coins,
        "relationships": relationships.duplicate(true),
        "farm_plots": farm_plots.duplicate(true),
        "owned_furniture": owned_furniture.duplicate(),
        "placed_furniture": placed_furniture.duplicate(true),
        "quest_status": quest_status.duplicate(true),
        "active_quest": active_quest,
        "story_chapter": story_chapter,
        "story_flags": story_flags.duplicate(true),
        "day_part": day_part,
        "season": season
    }

func load_snapshot(data: Dictionary) -> void:
    if data.is_empty():
        return
    coins = int(data.get("coins", STARTING_COINS))
    # Merge saved values over defaults so older/partial saves retain newly added NPC IDs.
    relationships = _merge_defaults({"yui": 0, "mina": 0, "bram": 0, "aoi": 0, "ren": 0, "hana": 0}, data.get("relationships", {}))
    farm_plots = data.get("farm_plots", {}).duplicate(true)
    owned_furniture.assign(data.get("owned_furniture", ["oak_cafe_table", "cushioned_stool"]))
    placed_furniture = data.get("placed_furniture", []).duplicate(true)
    quest_status = data.get("quest_status", {"q_reopen_cafe": "active"}).duplicate(true)
    active_quest = String(data.get("active_quest", "q_reopen_cafe"))
    story_chapter = int(data.get("story_chapter", 1))
    # Preserve new story flags when loading a save made before those flags existed.
    story_flags = _merge_defaults({"father_letter_found": false, "garden_restored": false, "all_spirit_memories": false}, data.get("story_flags", {}))
    day_part = String(data.get("day_part", "day"))
    season = String(data.get("season", "spring"))

func _merge_defaults(defaults: Dictionary, saved: Variant) -> Dictionary:
    var merged := defaults.duplicate(true)
    if saved is Dictionary:
        for key in saved:
            merged[key] = saved[key]
    return merged
