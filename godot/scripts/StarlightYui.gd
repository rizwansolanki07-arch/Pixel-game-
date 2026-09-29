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
  # Detailed 56px fallback Yui: readable hair, face, blouse, apron, skirt and boots.
  var outline:=Color("#292230")
  var hair:=Color("#302531")
  var skin:=Color("#e7a47f")
  var skin_hi:=Color("#f0b58d")
  var blouse:=Color("#d7a33f")
  var skirt:=Color("#9d3f44")
  var skirt_hi:=Color("#b94e48")
  var boot:=Color("#4a3031")
  # Hair silhouette and tied ponytail.
  draw_rect(Rect2(-13,-28,26,8),outline)
  draw_rect(Rect2(-11,-26,22,10),hair)
  draw_rect(Rect2(-14,-23,5,11),hair)
  draw_rect(Rect2(9,-24,6,16),hair)
  draw_rect(Rect2(12,-15,5,5),hair)
  # Face with ears and hair fringe.
  draw_rect(Rect2(-10,-19,20,14),skin)
  draw_rect(Rect2(-8,-21,16,4),hair)
  draw_rect(Rect2(-5,-18,3,3),Color("#3b2930"))
  draw_rect(Rect2(3,-18,3,3),Color("#3b2930"))
  draw_rect(Rect2(-2,-13,4,2),skin_hi)
  # Mustard blouse + warm collar.
  draw_rect(Rect2(-11,-5,22,9),blouse)
  draw_rect(Rect2(-4,-7,8,4),Color("#e8bd55"))
  # Red skirt with two readable folds.
  draw_rect(Rect2(-14,4,28,13),skirt)
  draw_rect(Rect2(-10,5,5,11),skirt_hi)
  draw_rect(Rect2(5,5,5,11),Color("#8b353f"))
  draw_rect(Rect2(-14,16,28,4),skirt)
  # Arms and hands.
  draw_rect(Rect2(-15,-4,4,11),skin_hi)
  draw_rect(Rect2(11,-4,4,11),skin_hi)
  draw_rect(Rect2(-16,6,5,4),skin)
  draw_rect(Rect2(11,6,5,4),skin)
  # Legs and boots.
  draw_rect(Rect2(-7,20,6,7),boot)
  draw_rect(Rect2(2,20,6,7),boot)
  draw_rect(Rect2(-10,26,9,3),outline)
  draw_rect(Rect2(1,26,9,3),outline)
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
