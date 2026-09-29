extends Node2D

# Yui presentation sprite: 56 px tall, 8 facings, 5-frame walk cycle.
const HEIGHT := 56.0
const WIDTH := 28.0
const WALK_FPS := 8.0
const FRAME_W := 56
const FRAME_H := 56

var move_direction := Vector2.DOWN
var moving := false
var walk_clock := 0.0
var facing_index := 0
var sprite_texture: Texture2D

const DIRS := [
 Vector2(0, 1), Vector2(-0.707, 0.707), Vector2(-1, 0),
 Vector2(-0.707, -0.707), Vector2(0, -1), Vector2(0.707, -0.707),
 Vector2(1, 0), Vector2(0.707, 0.707)
]

func _ready() -> void:
 sprite_texture=load("res://assets/starlight/characters/yui_8dir_5frame.png") as Texture2D
 queue_redraw()

func set_motion(direction: Vector2, is_moving: bool) -> void:
 if direction.length() > 0.05:
  move_direction=direction.normalized()
  facing_index=_nearest_direction(move_direction)
 moving=is_moving
 queue_redraw()

func _nearest_direction(direction: Vector2) -> int:
 var best:=0
 var best_dot:=-2.0
 for i in range(DIRS.size()):
  var score:=direction.dot(DIRS[i])
  if score>best_dot:
   best_dot=score
   best=i
 return best

func _process(delta: float) -> void:
 if moving:
  walk_clock+=delta*WALK_FPS
 else:
  walk_clock=0.0
 queue_redraw()

func _draw() -> void:
 if sprite_texture==null:
  return
 var frame:=int(floor(walk_clock))%5 if moving else 0
 var src:=Rect2(frame*FRAME_W,facing_index*FRAME_H,FRAME_W,FRAME_H)
 draw_texture_rect_region(sprite_texture,Rect2(-28,-28,56,56),src)
