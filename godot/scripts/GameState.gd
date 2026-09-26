extends Node

var map_id := "chanderi_village"
var player_position := Vector2(72, 120)
var quest_state := "not_started"
var world_flags: Dictionary = {}
var dialogue_open := false

func reset_new_game() -> void:
    map_id = "chanderi_village"
    player_position = Vector2(72, 120)
    quest_state = "not_started"
    world_flags = {}
    dialogue_open = false
