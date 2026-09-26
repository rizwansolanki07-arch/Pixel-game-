extends Node

var map_id := "chanderi_village"
var player_position := Vector2(72, 120)
var quest_state := "not_started"
var world_flags: Dictionary = {}
var dialogue_open := false

# Mobile virtual controls. These mirror normal Input actions without
# replacing keyboard/controller input.
var touch_move := Vector2.ZERO
var touch_interact := false
var touch_save := false

func reset_new_game() -> void:
    map_id = "chanderi_village"
    player_position = Vector2(72, 120)
    quest_state = "not_started"
    world_flags = {}
    dialogue_open = false
    touch_move = Vector2.ZERO
    touch_interact = false
    touch_save = false