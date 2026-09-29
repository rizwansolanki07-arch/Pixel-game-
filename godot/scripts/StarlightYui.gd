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
var idle_clock := 0.0

const DIRS := [
 Vector2(0, 1), Vector2(-0.707, 0.707), Vector2(-1, 0),
 Vector2(-0.707, -0.707), Vector2(0, -1), Vector2(0.707, -0.707),
 Vector2(1, 0), Vector2(0.707, 0.707)
]

func _ready() -> void:
 sprite_texture=null
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
 idle_clock += delta
 if moving:
  walk_clock+=delta*WALK_FPS
 else:
  walk_clock=0.0
 queue_redraw()

func _draw() -> void:
 # Ground shadow is deliberately tiny and hard-edged so Yui stays anchored to the 2:1 floor.
 _draw_ground_shadow()
 if sprite_texture==null:
  # 56px fallback Yui: chunky handcrafted pixel silhouette, kept on the same baseline.
  draw_rect(Rect2(-13,-28,26,8),Color("#292230"))
  draw_rect(Rect2(-10,-25,20,15),Color("#e7a47f"))
  draw_rect(Rect2(-8,-21,3,3),Color("#3b2930"))
  draw_rect(Rect2(5,-21,3,3),Color("#3b2930"))
  draw_rect(Rect2(-11,-11,22,7),Color("#d5a33d"))
  draw_rect(Rect2(-14,-4,28,17),Color("#9d3f44"))
  draw_rect(Rect2(-10,1,20,4),Color("#b94e48"))
  draw_rect(Rect2(-7,13,6,12),Color("#56363a"))
  draw_rect(Rect2(2,13,6,12),Color("#56363a"))
  draw_rect(Rect2(-9,24,8,3),Color("#30252d"))
  draw_rect(Rect2(1,24,8,3),Color("#30252d"))
  draw_rect(Rect2(-15,-5,4,11),Color("#e0a53f"))
  draw_rect(Rect2(11,-5,4,11),Color("#e0a53f"))
 var frame:=int(floor(walk_clock))%5 if moving else 0
 var src:=Rect2(frame*FRAME_W,facing_index*FRAME_H,FRAME_W,FRAME_H)
 var bob:=0.0 if moving else sin(idle_clock*2.2)*0.5
 if sprite_texture!=null: draw_texture_rect_region(sprite_texture,Rect2(-28,-28+bob,56,56),src)

func _draw_ground_shadow() -> void:
 # Pixel-cluster shadow: no antialiasing and no sub-pixel ellipse.
 var col:=Color(0.05,0.04,0.07,0.34)
 draw_rect(Rect2(-8,23,16,5),col)
 draw_rect(Rect2(-11,24,22,3),col)
 draw_rect(Rect2(-5,22,10,1),col)
