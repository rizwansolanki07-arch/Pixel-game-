extends Node2D

var font: Font

func _ready() -> void:
 font = ThemeDB.fallback_font
 queue_redraw()

func _process(_delta: float) -> void:
 queue_redraw()

func _draw() -> void:
 var night := StarlightGameState.phase == "night"
 var outline=Color("#241b27")
 var floor_a=Color("#a66a45") if not night else Color("#514153")
 var floor_b=Color("#8f5a42") if not night else Color("#46394d")
 var wall=Color("#704943") if not night else Color("#30283b")
 var wall_side=Color("#49343b") if not night else Color("#292737")
 var wood=Color("#74452f") if not night else Color("#4a3338")
 var wood_hi=Color("#c7834b") if not night else Color("#805349")
 var gold=Color("#efbd63") if not night else Color("#c99fe0")
 draw_rect(Rect2(0,0,384,216),Color("#151725") if night else Color("#26313a"))

 # Isometric cutaway walls.
 draw_colored_polygon(PackedVector2Array([Vector2(18,72),Vector2(190,20),Vector2(366,72),Vector2(190,126)]),wall)
 draw_colored_polygon(PackedVector2Array([Vector2(18,72),Vector2(190,126),Vector2(190,204),Vector2(18,111)]),wall_side)
 draw_colored_polygon(PackedVector2Array([Vector2(190,126),Vector2(366,72),Vector2(366,111),Vector2(190,204)]),Color("#5a3d3e") if not night else Color("#353041"))
 # Brick pattern.
 for i in range(6):
  var yy=43+i*13
  draw_line(Vector2(42,yy),Vector2(190,yy+45),Color("#8a5548") if not night else Color("#473548"),1)
  draw_line(Vector2(190,yy+45),Vector2(338,yy),Color("#7b4b43") if not night else Color("#3f3041"),1)
 # Timber frame.
 for p in [Vector2(64,59),Vector2(190,23),Vector2(316,59)]:
  draw_rect(Rect2(p.x-3,p.y,6,62),outline)
  draw_rect(Rect2(p.x-1,p.y+2,2,56),wood_hi)
 draw_line(Vector2(20,72),Vector2(190,126),wood_hi,4)
 draw_line(Vector2(190,126),Vector2(365,72),wood_hi,4)

 # 2:1 floor tiles.
 for y in range(0,5):
  for x in range(0,7):
   var p=Vector2(190,126)+Vector2((x-y)*32,(x+y)*16)
   var c=floor_a if (x+y)%2==0 else floor_b
   draw_colored_polygon(PackedVector2Array([p+Vector2(0,-16),p+Vector2(32,0),p+Vector2(0,16),p+Vector2(-32,0)]),c)
   draw_line(p+Vector2(-24,0),p+Vector2(0,12),Color(0.12,0.07,0.09,0.24),1)
   draw_line(p+Vector2(0,12),p+Vector2(24,0),Color(0.12,0.07,0.09,0.18),1)

 # Rugs.
 _rug(Vector2(93,151),Vector2(70,30),Color("#9a3e46") if not night else Color("#5c3650"))
 _rug(Vector2(291,158),Vector2(52,24),Color("#3f6370") if not night else Color("#35445e"))

 # Windows, curtains, art and clock.
 _window(Vector2(84,61),night)
 _window(Vector2(298,61),night)
 draw_rect(Rect2(42,47,30,21),outline)
 draw_rect(Rect2(45,50,24,15),Color("#597b68") if not night else Color("#45496d"))
 draw_colored_polygon(PackedVector2Array([Vector2(47,63),Vector2(56,54),Vector2(64,63)]),Color("#7c9c63"))
 draw_rect(Rect2(313,48,20,20),Color("#3b2a31"))
 draw_circle(Vector2(323,58),7,Color("#e8d8b2"))
 draw_line(Vector2(323,58),Vector2(323,53),outline,1)
 draw_line(Vector2(323,58),Vector2(327,60),outline,1)
 for i in range(7):
  var bx=108+i*23
  draw_colored_polygon(PackedVector2Array([Vector2(bx,52),Vector2(bx+12,52),Vector2(bx+6,60)]),[Color("#c84f51"),Color("#e1ae4d"),Color("#47778a")][i%3])
 _lamp(Vector2(143,50),night)
 _lamp(Vector2(235,50),night)

 # Left lounge and bookshelf.
 draw_rect(Rect2(35,100,42,34),Color("#4b3032"))
 draw_rect(Rect2(38,103,36,3),wood_hi)
 draw_rect(Rect2(38,119,36,3),wood_hi)
 for i in range(5):
  draw_rect(Rect2(41+i*6,108,4,9),[Color("#c47b55"),Color("#6f8d62"),Color("#9d6d4b")][i%3])
 _plant(Vector2(50,96),night)
 _sofa(Vector2(82,137),night)
 _small_table(Vector2(106,153))

 # Kitchen counter, jars and hanging pans.
 draw_colored_polygon(PackedVector2Array([Vector2(137,72),Vector2(247,39),Vector2(264,48),Vector2(153,83)]),Color("#75462f"))
 draw_colored_polygon(PackedVector2Array([Vector2(137,72),Vector2(153,83),Vector2(153,100),Vector2(137,89)]),Color("#432c32"))
 draw_colored_polygon(PackedVector2Array([Vector2(153,83),Vector2(264,48),Vector2(264,65),Vector2(153,100)]),Color("#513438"))
 for i in range(6):
  var x=161+i*15
  var y=72-i*4
  draw_rect(Rect2(x,y,10,10),Color("#a36b49"))
  draw_rect(Rect2(x+2,y+2,6,6),Color("#dcae63"))
 for i in range(5):
  var x=165+i*17
  var y=58-i*4
  draw_line(Vector2(x,y),Vector2(x,y+8),Color("#28232c"),1)
  draw_circle(Vector2(x,y+10),3,Color("#65616a"))

 # Stove / fireplace.
 draw_rect(Rect2(267,68,28,38),Color("#25232a"))
 draw_rect(Rect2(271,74,20,17),Color("#4b3431"))
 draw_rect(Rect2(274,77,14,11),Color("#e1743f") if not night else Color("#c95742"))
 draw_rect(Rect2(277,79,8,8),Color("#ffd16a"))
 draw_rect(Rect2(276,41,10,27),Color("#28252b"))
 draw_rect(Rect2(273,39,16,4),Color("#3b3239"))
 draw_rect(Rect2(256,103,50,4),Color("#3d2c31"))

 # Dining tables with food/flowers.
 _table(Vector2(191,143),Vector2(64,31),night,true)
 _table(Vector2(278,144),Vector2(43,22),night,false)
 _table(Vector2(221,171),Vector2(48,24),night,false)
 for p in [Vector2(150,145),Vector2(216,132),Vector2(255,153),Vector2(299,137),Vector2(221,183)]:
  _chair(p,night)
 # Living room layer: daytime customers, nighttime spirit.
 if not night:
  _guest(Vector2(260,145),Color("#cf8b72"),Color("#5b728c"),false)
  _guest(Vector2(315,150),Color("#b87963"),Color("#7a5c46"),true)
  draw_rect(Rect2(244,124,40,10),Color("#2e2635"))
  draw_string(font,Vector2(249,132),"READY" if StarlightGameState.current_recipe!="" else "ORDER",HORIZONTAL_ALIGNMENT_LEFT,-1,6,Color("#ffe7b0"))
 else:
  draw_circle(Vector2(221,143),18,Color(0.60,0.42,0.95,0.10))
  draw_circle(Vector2(221,143),10,Color(0.47,0.35,0.75,0.65))
  draw_circle(Vector2(218,141),2,Color("#e8dcff"))
  draw_circle(Vector2(224,141),2,Color("#e8dcff"))
  draw_rect(Rect2(216,145,10,5),Color("#73579a"))
  for sp in [Vector2(211,133),Vector2(231,136),Vector2(228,154)]: draw_rect(Rect2(sp.x,sp.y,2,2),Color("#d7c6ff"))
 # Small companion follows Yui through the room.
 var root=get_parent()
 if root and root.mode=="cafe":
  var cp:Vector2=root.player+Vector2(18,10)
  draw_circle(cp+Vector2(0,2),7,Color("#2e2732"))
  draw_circle(cp+Vector2(-4,-2),5,Color("#f4efe7"))
  draw_circle(cp+Vector2(4,-3),5,Color("#efe8de"))
  draw_circle(cp+Vector2(0,-6),5,Color("#fff8ef"))
  draw_rect(Rect2(cp.x-5,cp.y+1,2,2),Color("#2b2430"))
  draw_rect(Rect2(cp.x+3,cp.y+1,2,2),Color("#2b2430"))

 # Foreground props / entrance.
 for p in [Vector2(319,172),Vector2(338,178)]:
  draw_rect(Rect2(p.x-8,p.y-7,16,10),Color("#684333"))
  draw_rect(Rect2(p.x-6,p.y-5,12,2),wood_hi)
 draw_rect(Rect2(331,132,14,18),Color("#5a3b35"))
 draw_line(Vector2(334,135),Vector2(342,146),wood_hi,1)
 draw_line(Vector2(342,135),Vector2(334,146),wood_hi,1)
 _plant(Vector2(345,113),night)
 draw_colored_polygon(PackedVector2Array([Vector2(331,145),Vector2(350,139),Vector2(350,176),Vector2(331,184)]),Color("#3d2b31"))
 draw_rect(Rect2(331,145,19,4),wood_hi)

 # Tiny lived-in details and night atmosphere.
 for p in [Vector2(177,128),Vector2(207,132),Vector2(260,132),Vector2(300,121),Vector2(124,142)]:
  draw_rect(Rect2(p.x-2,p.y-2,4,3),gold)
 _detail_pass(night)
 _reference_detail_pass(night)
 if night:
  for p in [Vector2(143,53),Vector2(235,53),Vector2(281,84)]:
   draw_circle(p,16,Color(1.0,0.66,0.27,0.07))
  for i in range(20):
   var mx=28+(i*47)%330
   var my=43+(i*29)%130
   draw_rect(Rect2(mx,my,2,2),Color(0.75,0.67,1.0,0.42))

func _detail_pass(night:bool)->void:
 # Dense but readable handcrafted props, aligned to the 2:1 floor perspective.
 var outline:=Color("#241b27") if not night else Color("#171522")
 var hi:=Color("#d59a59") if not night else Color("#956b68")
 var clay:=Color("#8a5945") if not night else Color("#573e49")
 var leaf:=Color("#5e8c52") if not night else Color("#4e6c58")
 # Countertop plates, bowls and cups.
 for p in [Vector2(174,69),Vector2(192,64),Vector2(211,59),Vector2(230,54)]:
  draw_rect(Rect2(p.x-3,p.y,6,2),Color("#e8d7b0"))
  draw_rect(Rect2(p.x-2,p.y-2,4,2),clay)
  draw_rect(Rect2(p.x-1,p.y-1,2,1),hi)
 # Hanging herbs and copper utensils above the kitchen.
 for i in range(6):
  var x:=146.0+i*11.0
  draw_line(Vector2(x,44),Vector2(x,53),outline,1)
  draw_rect(Rect2(x-2,52,4,4),leaf)
  draw_rect(Rect2(x+4,45,2,7),hi)
 # Shelf labels and small jars.
 for i in range(6):
  var x:=166.0+i*15.0
  draw_rect(Rect2(x,86,9,10),clay)
  draw_rect(Rect2(x+2,88,5,5),[Color("#d47d58"),Color("#6f9661"),Color("#d3b06a")][i%3])
  draw_rect(Rect2(x+2,94,5,1),outline)
 # Chalkboard/menu on the left wall.
 draw_rect(Rect2(42,73,42,22),outline)
 draw_rect(Rect2(45,76,36,16),Color("#30483e") if not night else Color("#28363a"))
 draw_string(font,Vector2(49,83),"MENU",HORIZONTAL_ALIGNMENT_LEFT,-1,6,Color("#f1d28e") if not night else Color("#cbbce9"))
 draw_line(Vector2(49,86),Vector2(74,86),Color("#d8bf83"),1)
 draw_line(Vector2(49,89),Vector2(68,89),Color("#d8bf83"),1)
 # Wall frames and family photo.
 draw_rect(Rect2(92,78,25,18),outline)
 draw_rect(Rect2(95,81,19,12),Color("#6b8b7b") if not night else Color("#4d526b"))
 draw_rect(Rect2(101,83,5,6),Color("#d5a26a"))
 # Candles on the dining tables.
 for p in [Vector2(191,136),Vector2(277,139),Vector2(221,167)]:
  draw_rect(Rect2(p.x-1,p.y-6,2,6),Color("#f2dfb4"))
  draw_rect(Rect2(p.x-2,p.y-1,4,2),clay)
  draw_rect(Rect2(p.x-1,p.y-8,2,2),Color("#f3bf63") if not night else Color("#d5a4df"))
 # Floor scatter: tiny rugs, crumbs and wood knots, kept sparse.
 for p in [Vector2(132,151),Vector2(154,164),Vector2(246,160),Vector2(302,154),Vector2(198,188)]:
  draw_rect(Rect2(p.x,p.y,3,1),hi)
  draw_rect(Rect2(p.x+5,p.y+2,2,1),outline)
 # Left plant gets a pot rim and leaf highlights.
 draw_rect(Rect2(46,102,9,2),hi)
 for p in [Vector2(45,95),Vector2(52,91),Vector2(57,97)]:
  draw_rect(Rect2(p.x,p.y,3,3),leaf)
 # Door frame, handle and welcome mat.
 draw_rect(Rect2(328,102,24,3),hi)
 draw_rect(Rect2(328,159,24,3),hi)
 draw_rect(Rect2(340,130,3,3),Color("#e4b76a"))
 _rug(Vector2(338,169),Vector2(30,14),Color("#74464a") if not night else Color("#493a50"))


func _reference_detail_pass(night:bool)->void:
 # Reference-matching micro-detail layer: curtains, shelf clutter, stove kettle/firewood,
 # wall art, vines and table service. All shapes stay on the 2:1 isometric footprint.
 var outline:=Color("#241b27") if not night else Color("#171522")
 var wood_hi:=Color("#c9874f") if not night else Color("#7f554c")
 var cloth:=Color("#b34f50") if not night else Color("#673c4e")
 var cream:=Color("#f0dfbb") if not night else Color("#cfc2df")
 var green:=Color("#5d8a53") if not night else Color("#4c6b58")

 # Window curtains and tie-backs.
 for x in [84.0,298.0]:
  draw_colored_polygon(PackedVector2Array([
   Vector2(x-22,48),Vector2(x-14,51),Vector2(x-17,77),Vector2(x-25,72)
  ]),Color("#d5b27f") if not night else Color("#75637b"))
  draw_colored_polygon(PackedVector2Array([
   Vector2(x+22,48),Vector2(x+14,51),Vector2(x+17,77),Vector2(x+25,72)
  ]),Color("#c9a56f") if not night else Color("#6c5b72"))
  draw_rect(Rect2(x-17,62,4,2),wood_hi)
  draw_rect(Rect2(x+13,62,4,2),wood_hi)

 # Tall left bookshelf packed with readable pixel clusters.
 draw_rect(Rect2(34,93,44,39),outline)
 draw_rect(Rect2(38,97,36,31),Color("#633e35") if not night else Color("#44333b"))
 for row in range(3):
  draw_line(Vector2(39,106+row*9),Vector2(73,106+row*9),wood_hi,1)
  for i in range(6):
   var bx:=41.0+i*5.0
   draw_rect(Rect2(bx,98+row*9,3,7),[Color("#b56b4d"),Color("#70885e"),Color("#d0a35d")][(i+row)%3])
 draw_rect(Rect2(32,129,48,3),wood_hi)

 # Counter serviceware: bowls, plates, cutting board and kettle.
 for p in [Vector2(171,68),Vector2(190,63),Vector2(209,58),Vector2(229,53)]:
  draw_rect(Rect2(p.x-4,p.y,8,2),cream)
  draw_rect(Rect2(p.x-2,p.y-3,4,3),Color("#8a5945") if not night else Color("#563d48"))
 draw_rect(Rect2(236,48,9,7),Color("#8b5a45") if not night else Color("#563b43"))
 draw_rect(Rect2(244,46,5,2),wood_hi)
 draw_rect(Rect2(247,43,2,5),outline)

 # Hanging pan / ladle silhouettes.
 for i in range(4):
  var hx:=156.0+i*18.0
  draw_line(Vector2(hx,43),Vector2(hx,51),outline,1)
  draw_circle(Vector2(hx,54),4,Color("#57505a") if not night else Color("#403b48"))
  draw_rect(Rect2(hx-1,57,2,5),wood_hi)

 # Stove kettle, firewood basket and stronger hearth glow.
 draw_rect(Rect2(273,67,18,3),outline)
 draw_rect(Rect2(277,62,11,7),Color("#6d4a42") if not night else Color("#47343d"))
 draw_rect(Rect2(280,59,5,4),Color("#9b6b4c") if not night else Color("#5e4550"))
 draw_rect(Rect2(256,93,10,9),outline)
 for i in range(4):
  draw_line(Vector2(258+i*2,94),Vector2(263+i*2,100),wood_hi,1)
 if night:
  draw_circle(Vector2(281,83),17,Color(1.0,0.55,0.22,0.07))

 # Central table service: patterned runner, vase, flowers, cups and bread.
 draw_colored_polygon(PackedVector2Array([
  Vector2(169,140),Vector2(191,132),Vector2(213,140),Vector2(191,148)
 ]),cloth)
 draw_rect(Rect2(188,133,6,2),Color("#e1a65d"))
 draw_rect(Rect2(190,128,3,6),Color("#5b754d"))
 draw_rect(Rect2(186,127,4,3),green)
 draw_rect(Rect2(193,126,4,3),Color("#d9a86c"))
 for p in [Vector2(177,137),Vector2(203,139)]:
  draw_circle(p,2,cream)
  draw_rect(Rect2(p.x-1,p.y-3,2,2),wood_hi)

 # Right tables get their own distinct runner/placemat and books.
 draw_line(Vector2(264,143),Vector2(292,149),Color("#5c83a0") if not night else Color("#4c5c7a"),3)
 draw_rect(Rect2(275,143,7,3),cream)
 draw_rect(Rect2(283,145,8,3),Color("#694a5b") if not night else Color("#443746"))
 draw_line(Vector2(204,169),Vector2(236,176),Color("#a64d50") if not night else Color("#5d3d50"),3)
 draw_rect(Rect2(217,170,6,3),cream)

 # Entrance vine, flowers and welcome detail.
 for i in range(5):
  var vx:=332.0+i*4.0
  draw_line(Vector2(vx,105+i*2),Vector2(vx-2,126+i*2),Color("#3e6747"),2)
  draw_rect(Rect2(vx-5,121+i*2,5,5),green)
  if i%2==0:
   draw_rect(Rect2(vx-1,118+i*2,3,3),Color("#e6c2b4") if not night else Color("#c5a6ca"))

 # Wall clock and framed landscape remain small but readable.
 draw_rect(Rect2(314,45,18,18),outline)
 draw_circle(Vector2(323,54),6,Color("#efe1bd"))
 draw_line(Vector2(323,54),Vector2(323,50),outline,1)
 draw_line(Vector2(323,54),Vector2(326,56),outline,1)
 draw_rect(Rect2(42,47,31,20),outline)
 draw_rect(Rect2(46,50,23,14),Color("#507568") if not night else Color("#4d4a67"))
 draw_colored_polygon(PackedVector2Array([Vector2(48,62),Vector2(56,54),Vector2(64,62)]),Color("#8aa064"))

 # Small foreground crate/barrel cluster.
 for p in [Vector2(311,169),Vector2(329,178)]:
  draw_rect(Rect2(p.x-7,p.y-7,14,10),Color("#654234") if not night else Color("#44343b"))
  draw_line(Vector2(p.x-6,p.y-3),Vector2(p.x+6,p.y+1),wood_hi,1)
  draw_rect(Rect2(p.x-5,p.y-6,10,2),wood_hi)

func _rug(c:Vector2,size:Vector2,col:Color)->void:
 var hw=size.x*0.5
 var hh=size.y*0.5
 draw_colored_polygon(PackedVector2Array([c+Vector2(0,-hh),c+Vector2(hw,0),c+Vector2(0,hh),c-Vector2(hw,0)]),col)
 draw_polyline(PackedVector2Array([c+Vector2(0,-hh+2),c+Vector2(hw-3,0),c+Vector2(0,hh-2),c-Vector2(hw-3,0),c+Vector2(0,-hh+2)]),Color("#e0b06a"),1)

func _window(p:Vector2,night:bool)->void:
 draw_rect(Rect2(p.x-24,p.y-12,48,30),Color("#2a2029"))
 draw_rect(Rect2(p.x-19,p.y-7,38,20),Color("#638c9c") if not night else Color("#4a456e"))
 draw_line(Vector2(p.x,p.y-7),Vector2(p.x,p.y+13),Color("#654038"),2)
 draw_line(Vector2(p.x-19,p.y+3),Vector2(p.x+19,p.y+3),Color("#654038"),2)
 draw_rect(Rect2(p.x-25,p.y-13,5,32),Color("#b4775c"))
 draw_rect(Rect2(p.x+20,p.y-13,5,32),Color("#9c624f"))
 if night:
  draw_circle(p+Vector2(8,-1),5,Color("#e5d2a2"))
 else:
  draw_colored_polygon(PackedVector2Array([p+Vector2(-17,12),p+Vector2(-7,5),p+Vector2(0,12)]),Color("#4e7655"))
  draw_colored_polygon(PackedVector2Array([p+Vector2(3,12),p+Vector2(12,4),p+Vector2(18,12)]),Color("#3e654d"))

func _lamp(p:Vector2,night:bool)->void:
 draw_line(p+Vector2(0,-13),p+Vector2(0,-2),Color("#30262f"),2)
 draw_rect(Rect2(p.x-5,p.y-1,10,7),Color("#8d5942"))
 draw_rect(Rect2(p.x-3,p.y,6,5),Color("#f0bf62"))
 if night: draw_circle(p+Vector2(0,3),14,Color(1.0,0.65,0.24,0.09))

func _plant(p:Vector2,night:bool)->void:
 draw_rect(Rect2(p.x-5,p.y+5,10,9),Color("#70483d"))
 for off in [Vector2(-6,1),Vector2(0,-5),Vector2(6,1),Vector2(3,5)]:
  draw_rect(Rect2(p+off,Vector2(6,6)),Color("#456d4d") if night else Color("#5f8b4f"))

func _sofa(c:Vector2,night:bool)->void:
 var base=Color("#365243") if night else Color("#5b7949")
 draw_colored_polygon(PackedVector2Array([c+Vector2(-31,-9),c+Vector2(0,-19),c+Vector2(31,-8),c+Vector2(0,2)]),base)
 draw_colored_polygon(PackedVector2Array([c+Vector2(-31,-9),c+Vector2(0,2),c+Vector2(0,16),c+Vector2(-31,5)]),Color("#293b38") if night else Color("#48623f"))
 draw_colored_polygon(PackedVector2Array([c+Vector2(0,2),c+Vector2(31,-8),c+Vector2(31,5),c+Vector2(0,16)]),Color("#30473a") if night else Color("#4e693f"))
 draw_rect(Rect2(c.x-10,c.y-4,15,5),Color("#b75a4f"))
 draw_rect(Rect2(c.x+7,c.y-2,12,4),Color("#d7a14f"))

func _small_table(c:Vector2)->void:
 draw_colored_polygon(PackedVector2Array([c+Vector2(0,-7),c+Vector2(18,0),c+Vector2(0,7),c+Vector2(-18,0)]),Color("#9a6241"))
 draw_line(c+Vector2(-10,2),c+Vector2(-13,13),Color("#4a3031"),2)
 draw_line(c+Vector2(10,2),c+Vector2(13,13),Color("#4a3031"),2)
 draw_rect(Rect2(c.x-2,c.y-5,4,3),Color("#e6b76a"))

func _table(c:Vector2,size:Vector2,night:bool,hero_table:bool)->void:
 var hw=size.x*0.5
 var hh=size.y*0.5
 draw_colored_polygon(PackedVector2Array([c+Vector2(0,-hh),c+Vector2(hw,0),c+Vector2(0,hh),c-Vector2(hw,0)]),Color("#a96a43") if not night else Color("#754634"))
 draw_colored_polygon(PackedVector2Array([c+Vector2(-hw,0),c,c+Vector2(0,hh),c-Vector2(hw,0)]),Color("#71433a") if not night else Color("#4c3237"))
 draw_colored_polygon(PackedVector2Array([c,c+Vector2(hw,0),c+Vector2(0,hh),c-Vector2(hw,0)]),Color("#603a37") if not night else Color("#402e35"))
 draw_line(c+Vector2(-hw+4,0),c+Vector2(hw-4,0),Color("#d99a58"),1)
 draw_line(c+Vector2(-hw+8,3),c+Vector2(hw-7,3),Color("#6c3c39"),1)
 draw_line(c+Vector2(-10,hh+2),c+Vector2(-13,16),Color("#493039"),2)
 draw_line(c+Vector2(10,hh+2),c+Vector2(13,16),Color("#3b2a32"),2)
 if hero_table:
  draw_colored_polygon(PackedVector2Array([c+Vector2(-22,-1),c+Vector2(0,-8),c+Vector2(22,-1),c+Vector2(0,6)]),Color("#a94446"))
  draw_rect(Rect2(c.x-2,c.y-6,4,3),Color("#f0d08c"))
  draw_rect(Rect2(c.x+7,c.y-3,4,3),Color("#e6b35d"))
 else:
  draw_rect(Rect2(c.x-2,c.y-5,4,3),Color("#e7c37b"))

func _chair(p:Vector2,night:bool)->void:
 var sh=Color("#3a2930") if night else Color("#59383a")
 var hi=Color("#9a5d3e") if night else Color("#b87345")
 draw_rect(Rect2(p.x-7,p.y-12,14,6),sh)
 draw_rect(Rect2(p.x-5,p.y-11,10,3),hi)
 draw_colored_polygon(PackedVector2Array([p+Vector2(-8,-5),p+Vector2(8,-5),p+Vector2(7,4),p+Vector2(-7,4)]),hi)
 draw_line(p+Vector2(-5,4),p+Vector2(-7,15),sh,2)
 draw_line(p+Vector2(5,4),p+Vector2(7,15),sh,2)

func _guest(p:Vector2,skin:Color,cloth:Color,hat:bool)->void:
 draw_circle(p+Vector2(0,-6),5,skin)
 if hat:
  draw_rect(Rect2(p.x-6,p.y-12,12,4),Color("#4c4d63"))
  draw_rect(Rect2(p.x-4,p.y-15,8,3),Color("#5d6579"))
 draw_colored_polygon(PackedVector2Array([p+Vector2(-5,-1),p+Vector2(5,-1),p+Vector2(7,9),p+Vector2(-7,9)]),cloth)
 draw_rect(Rect2(p.x-5,p.y+9,4,5),Color("#2f2931"))
 draw_rect(Rect2(p.x+1,p.y+9,4,5),Color("#2f2931"))
