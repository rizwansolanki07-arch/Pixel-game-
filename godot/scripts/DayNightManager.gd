extends Node

signal phase_changed(phase: String)

var phase := "day"
var cycle_seconds := 120.0
var elapsed := 0.0

func _process(delta: float) -> void:
    elapsed += delta
    if elapsed >= cycle_seconds:
        elapsed = 0.0
        phase = "night" if phase == "day" else "day"
        if phase == "day":
            StarlightGameState.day += 1
        StarlightGameState.phase = phase
        phase_changed.emit(phase)

func set_phase(next_phase: String) -> void:
    if next_phase != "day" and next_phase != "night":
        return
    phase = next_phase
    elapsed = 0.0
    StarlightGameState.phase = phase
    phase_changed.emit(phase)
