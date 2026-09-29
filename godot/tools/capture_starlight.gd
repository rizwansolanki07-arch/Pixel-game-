extends SceneTree

func _init() -> void:
    var packed: PackedScene = load("res://scenes/StarlightCafe.tscn") as PackedScene
    var scene: Node = packed.instantiate()
    root.add_child(scene)
    call_deferred("_capture_views", scene)

func _capture_views(scene: Node) -> void:
    await process_frame
    scene.mode = "cafe"
    scene.cafe_opened = true
    scene.queue_redraw()
    await process_frame
    await create_timer(0.25).timeout

    var viewport: Viewport = root.get_viewport()
    var day_image: Image = viewport.get_texture().get_image()
    day_image.save_png("res://capture_cafe_day.png")

    var day_night: Node = root.get_node_or_null("DayNightManager")
    if day_night != null:
        day_night.call("set_phase", "night")
    else:
        var state: Node = root.get_node_or_null("StarlightGameState")
        if state != null:
            state.set("phase", "night")
    scene.queue_redraw()
    await process_frame
    await create_timer(0.25).timeout

    var night_image: Image = viewport.get_texture().get_image()
    night_image.save_png("res://capture_cafe_night.png")

    quit(0)
