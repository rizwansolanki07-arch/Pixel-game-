extends Node

const GAME_ID := "starlight_cafe"
const CHARACTER_HEIGHT_PX := 56
const FLOOR_TILE := Vector2i(64, 32)
const WORLD_CM := 90.0

var day: int = 1
var phase: String = "day"
var player_position: Vector2 = Vector2.ZERO
var inventory: Dictionary = {}
var unlocked_recipes: Array[String] = ["moon_mushroom_soup"]
var spirit_progress: Dictionary = {"spirit_001": 0}
var cafe_opened := false
var touch_move := Vector2.ZERO
var current_recipe: String = ""
var story_flags: Dictionary = {}

func begin_day() -> void:
    phase = "day"

func begin_night() -> void:
    phase = "night"

func add_item(item_id: String, amount: int = 1) -> void:
    inventory[item_id] = int(inventory.get(item_id, 0)) + amount

func consume_item(item_id: String, amount: int = 1) -> bool:
    var have := int(inventory.get(item_id, 0))
    if have < amount:
        return false
    inventory[item_id] = have - amount
    return true

func can_cook(recipe: Dictionary) -> bool:
    for ingredient in recipe.get("ingredients", []):
        var id := String(ingredient.get("id", ""))
        var amount := int(ingredient.get("amount", 1))
        if int(inventory.get(id, 0)) < amount:
            return false
    return true

func cook(recipe: Dictionary) -> bool:
    if not can_cook(recipe):
        return false
    for ingredient in recipe.get("ingredients", []):
        consume_item(String(ingredient.get("id", "")), int(ingredient.get("amount", 1)))
    return true
