extends SceneTree

func _init() -> void:
    var packed: PackedScene = load("res://scenes/StarlightCafe.tscn")
    var scene := packed.instantiate()
    root.add_child(scene)
    call_deferred("_finish_after_render")

func _finish_after_render() -> void:
    await process_frame
    await create_timer(1.2).timeout
    quit(0)
