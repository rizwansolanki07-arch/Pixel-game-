extends SceneTree

func _init() -> void:
    var scene := load("res://scenes/StarlightCafe.tscn").instantiate()
    root.add_child(scene)
    call_deferred("_capture_views", scene)

func _capture_views(scene: Node) -> void:
    await process_frame
    scene.mode = "cafe"
    scene.cafe_opened = true
    scene.queue_redraw()
    await create_timer(0.4).timeout
    var day_image := get_viewport().get_texture().get_image()
    day_image.save_png("res://capture_cafe_day.png")

    DayNightManager.set_phase("night")
    scene.queue_redraw()
    await create_timer(0.4).timeout
    var night_image := get_viewport().get_texture().get_image()
    night_image.save_png("res://capture_cafe_night.png")

    quit(0)
