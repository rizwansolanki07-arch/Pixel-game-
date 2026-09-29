extends Node2D

const CAFE := Rect2(76,48,250,128)
const SPEED := 95.0

var player := Vector2(154,146)
var village_player := Vector2(180,158)
var mode := "title"
var language := "EN"
var msg := ""
var msg_time := 0.0
var touch_move := Vector2.ZERO
var cooking := ""
var cook_time := 0.0
var cook_len := 2.5
var panel := ""
var door_open := false
var gathered := {}
var quest_stage := 0
var cafe_opened := false
var font: Font
var dialogue: Node2D
var touch: Node2D
var yui: Node2D
var cafe_day_tex: Texture2D
var cafe_night_tex: Texture2D
var near_target := ""
var ui_pulse := 0.0
var capture_clock := 0.0

var recipes := {
 "moon_mushroom_soup":{"name":"Moonlight Mushroom Soup","ingredients":{"moon_mushroom":1,"village_herb":2,"milk":1,"salt":1},"spirit":"spirit_001"},
 "starlight_tea":{"name":"Starlight Tea","ingredients":{"village_herb":1,"honey":1},"spirit":"spirit_001"},
 "dawn_porridge":{"name":"Dawn Porridge","ingredients":{"milk":1,"grain":2,"honey":1},"spirit":"spirit_002"}
}
var spirits := {
 "spirit_001":{"name":"Aoi","recipe":"moon_mushroom_soup","day":1},
 "spirit_002":{"name":"Ren","recipe":"dawn_porridge","day":2}
}

func _ready():
 font=ThemeDB.fallback_font
 dialogue=$Dialogue; touch=$TouchControls; yui=$Yui
 cafe_day_tex=load("res://assets/starlight/environment/cafe_day.png") as Texture2D
 cafe_night_tex=load("res://assets/starlight/environment/cafe_night.png") as Texture2D
 touch.move_changed.connect(_touch_move)
 touch.interact_pressed.connect(_touch_interact)
 dialogue.finished.connect(_dialogue_finished)
 var capture_mode:=OS.get_environment("STARLIGHT_CAPTURE")
 if capture_mode!="":
  mode="cafe"
  cafe_opened=true
  StarlightGameState.cafe_opened=true
  StarlightGameState.phase="night" if capture_mode=="night" else "day"
 if StarlightSaveManager.load_game() and capture_mode=="":
  mode="cafe"; cafe_opened=StarlightGameState.cafe_opened; player=StarlightGameState.player_position
  quest_stage=int(StarlightGameState.story_flags.get("quest_stage",0))
  language=str(StarlightGameState.story_flags.get("language","EN"))
 queue_redraw()

func _process(delta):
 msg_time=maxf(0,msg_time-delta)
 ui_pulse += delta
 var cap:=OS.get_environment("STARLIGHT_CAPTURE")
 if cap!="":
  capture_clock += delta
  if capture_clock>0.6:
   var im:Image=get_viewport().get_texture().get_image()
   if cap=="night":
    im.save_png("res://capture_cafe_night.png")
   else:
    im.save_png("res://capture_cafe_day.png")
   call_deferred("queue_free")
 if mode=="title": queue_redraw(); return
 if mode=="village": _move_village(delta)
 else:
  _move_cafe(delta)
  if cooking!="":
   cook_time+=delta
   if cook_time>=cook_len: _finish_cooking()
  yui.position=player
  near_target=_nearest()
  var mv=touch_move if touch_move.length()>0.05 else Input.get_vector("move_left","move_right","move_up","move_down")
  yui.set_motion(mv,mv.length()>0.05)
 queue_redraw()

func _input(e):
 if mode=="title":
  if e.is_action_pressed("interact") or (e is InputEventScreenTouch and e.pressed): _start()
  return
 if dialogue.active: return
 if e.is_action_pressed("interact"): _interact()
 if e.is_action_pressed("save_game"): _save()
 if e is InputEventKey and e.pressed and not e.echo:
  match e.keycode:
   KEY_I: panel="" if panel=="inventory" else "inventory"
   KEY_R: panel="" if panel=="recipes" else "recipes"
   KEY_Q: panel="" if panel=="quest" else "quest"
   KEY_F: panel="" if panel=="settings" else "settings"
   KEY_L: language="HI" if language=="EN" else "EN"
   KEY_N: DayNightManager.set_phase("night")
   KEY_D: DayNightManager.set_phase("day")
   KEY_V: _enter_village() if mode=="cafe" else _return_cafe()
   KEY_C: _cook_best()

func _start():
 mode="cafe"; cafe_opened=true; StarlightGameState.cafe_opened=true
 _say(_t("Yui: Papa ka café phir se kholna hai.","Yui: I have to reopen Papa's café."),3)

func _move_cafe(d):
 var v=Input.get_vector("move_left","move_right","move_up","move_down")
 if touch_move.length()>v.length(): v=touch_move
 if v.length()<=.01: return
 v=v.normalized()*SPEED*d
 var nx=player+Vector2(v.x,0); var ny=player+Vector2(0,v.y)
 if _cafe_ok(nx): player=nx
 if _cafe_ok(ny): player=ny
 StarlightGameState.player_position=player

func _cafe_ok(p):
 var floor_poly:=PackedVector2Array([
  Vector2(12,112),Vector2(190,22),Vector2(373,111),Vector2(190,202)
 ])
 if not Geometry2D.is_point_in_polygon(p,floor_poly): return false
 if p.y<65 or p.y>199: return false
 for b in [
  Rect2(146,48,112,48),
  Rect2(54,128,72,30),
  Rect2(160,103,64,28),
  Rect2(274,125,54,30),
  Rect2(258,86,42,48),
  Rect2(42,91,48,60),
  Rect2(296,100,44,55)
 ]:
  if b.grow(4).has_point(p): return false
 return true

func _move_village(d):
 var v=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
 if touch_move.length()>.05: v=touch_move
 if v.length()<=.01: return
 v=v.normalized()*SPEED*d
 var nx=village_player+Vector2(v.x,0); var ny=village_player+Vector2(0,v.y)
 if _village_ok(nx): village_player=nx
 if _village_ok(ny): village_player=ny

func _village_ok(p):
 if p.x<58 or p.x>326 or p.y<58 or p.y>166: return false
 for b in [Rect2(126,42,70,58),Rect2(88,66,44,34),Rect2(212,46,62,52),Rect2(190,88,62,52),Rect2(268,112,30,36),Rect2(64,102,44,24),Rect2(270,140,44,22)]:
  if b.grow(5).has_point(p): return false
 return true

func _nearest():
 var t={
  "moon_mushroom":Vector2(135,176),
  "village_herb":Vector2(333,153),
  "milk":Vector2(214,49),
  "salt":Vector2(176,47),
  "honey":Vector2(258,48),
  "grain":Vector2(198,48),
  "counter":Vector2(202,70),
  "door":Vector2(345,171),
  "spirit":Vector2(235,122),
  "guest_1":Vector2(260,145),
  "guest_2":Vector2(315,150)
 }
 var best=""; var bd=999.0
 for k in t:
  var dd=player.distance_to(t[k])
  if dd<27 and dd<bd: best=k; bd=dd
 return best

func _interact():
 if mode=="village": _village_interact(); return
 var t=_nearest()
 if t=="": _say(_t("Kisi cheez ke paas jao.","Move closer to something."),1.5); return
 if t=="counter": _cook_best(); return
 if t=="door":
  door_open=!door_open; _say(_t("Darwaza khul gaya.","Door opened.") if door_open else _t("Darwaza band hai.","Door closed."),1.5); return
 if t=="spirit": _spirit(); return
 if t=="guest_1" or t=="guest_2":
  _serve_customer(t)
  return
 var key=str(StarlightGameState.day)+"_"+t
 if gathered.has(key): _say(_t("Aaj yahan se aur kuch nahi mila.","Nothing more here today."),1.5)
 else:
  var n=2 if t=="village_herb" or t=="grain" else 1
  StarlightGameState.add_item(t,n); gathered[key]=true; _say(t.replace("_"," ").capitalize()+" +"+str(n),2)
 _quest()

func _serve_customer(customer_id:String)->void:
 if StarlightGameState.phase!="day":
  _say(_t("Raat ko sirf rooh wale mehmaan aate hain.","Only spirit guests come at night."),2)
  return
 if StarlightGameState.current_recipe=="":
  _say(_t("Mehmaan order ka intezar kar raha hai.","The guest is waiting for an order."),2)
  return
 var served:int=int(StarlightGameState.story_flags.get("customers_served",0))+1
 StarlightGameState.story_flags["customers_served"]=served
 StarlightGameState.current_recipe=""
 _say(_t("Mehmaan ko dish serve ki • "+str(served)+" served","Dish served to guest • "+str(served)+" served"),2.2)
 _quest()

func _village_interact():
 var p=village_player
 if p.distance_to(Vector2(142,116))<22: StarlightGameState.add_item("village_herb",1); _say("Village Herb +1",2); return
 if p.distance_to(Vector2(108,92))<22: dialogue.begin("Mina",[_t("Bazaar mein fresh herbs aur honey milega.","Fresh herbs and honey are sold here."),_t("Raat se pehle café lautna.","Return before night.")]); return
 if p.distance_to(Vector2(244,86))<22: dialogue.begin("Bram",[_t("Aaj raat phir roshni dikhegi.","The light will return tonight."),_t("Kuch mehmaan sirf raat ko aate hain.","Some guests only visit at night.")]); return
 if p.distance_to(Vector2(161,98))<25: dialogue.begin("Innkeeper",[_t("Greenhollow tumhare saath hai.","Greenhollow is with you." )]); return
 if p.distance_to(Vector2(221,136))<25: _say(_t("Mandir ki ghanti bajti hai.","The shrine bell rings softly."),2); return
 if p.distance_to(Vector2(282,130))<22: _say(_t("Kuen mein chaand ka aks hai.","The old well reflects the moon."),2); return
 if p.distance_to(Vector2(213,160))<22: _return_cafe()

func _can(id):
 for k in recipes[id].ingredients:
  if int(StarlightGameState.inventory.get(k,0))<int(recipes[id].ingredients[k]): return false
 return true

func _cook_best():
 if cooking!="": _say(_t("Cooking chal rahi hai.","Cooking is already running."),1.5); return
 for id in ["moon_mushroom_soup","starlight_tea","dawn_porridge"]:
  if id in StarlightGameState.unlocked_recipes and _can(id):
   cooking=id; cook_time=0; _say("Cooking: "+recipes[id].name,2); return
 _say(_t("Ingredients kam hain.","Not enough ingredients."),2)

func _finish_cooking():
 var id=cooking; cooking=""; cook_time=0
 for k in recipes[id].ingredients: StarlightGameState.consume_item(k,int(recipes[id].ingredients[k]))
 StarlightGameState.current_recipe=id; _say(recipes[id].name+" ready!",3); _quest()

func _spirit():
 if StarlightGameState.phase!="night": _say(_t("Raat ko mehmaan aayega.","A guest arrives at night."),2); return
 var sid="spirit_001" if StarlightGameState.day<2 else "spirit_002"
 var s=spirits[sid]
 if int(StarlightGameState.spirit_progress.get(sid,0))>=1:
  dialogue.begin(s.name,[_t("Meri kahani ka ek tukda roshan ho gaya.","A piece of my story is lit again."),_t("Kal phir milenge.","See you tomorrow.")]); return
 if StarlightGameState.current_recipe==s.recipe:
  StarlightGameState.current_recipe=""; StarlightGameState.spirit_progress[sid]=1
  if sid=="spirit_001":
   dialogue.begin("Aoi",[_t("Yeh soup bilkul ghar jaisi hai.","This soup tastes like home."),_t("Mujhe yaad aa gaya main yahan kyun aati thi.","I remember why I came here.")])
   if "starlight_tea" not in StarlightGameState.unlocked_recipes: StarlightGameState.unlocked_recipes.append("starlight_tea")
  else:
   dialogue.begin("Ren",[_t("Dawn porridge meri maa banati thi.","My mother made dawn porridge."),_t("Tumne meri subah wapas kar di.","You gave me my morning back.")])
  _quest()
 else: dialogue.begin(s.name,[_t("Mujhe meri favorite dish chahiye.","I need my favorite dish."),_t("Kya tum banaogi?","Will you make it?")])

func _quest():
 if quest_stage==0 and int(StarlightGameState.inventory.get("moon_mushroom",0))>0: quest_stage=1
 if quest_stage==1 and StarlightGameState.current_recipe=="moon_mushroom_soup": quest_stage=2
 if quest_stage==2 and int(StarlightGameState.spirit_progress.get("spirit_001",0))>0: quest_stage=3
 if quest_stage==3 and "starlight_tea" in StarlightGameState.unlocked_recipes: quest_stage=4
 if quest_stage==4 and StarlightGameState.day>=2: quest_stage=5
 StarlightGameState.story_flags["quest_stage"]=quest_stage

func _quest_text():
 return [_t("Quest: Moon mushroom dhoondo.","Quest: Find a moon mushroom."),_t("Quest: Moonlight Mushroom Soup banao.","Quest: Cook Moonlight Mushroom Soup."),_t("Quest: Aoi ko soup serve karo.","Quest: Serve soup to Aoi."),_t("Chapter 1 complete — Starlight Tea unlock.","Chapter 1 complete — Starlight Tea unlocked."),_t("Chapter 2: Dawn Porridge ke ingredients dhoondo.","Chapter 2: Find Dawn Porridge ingredients."),_t("Chapter 2 complete — Ren ki kahani roshan hui.","Chapter 2 complete — Ren's story is lit.")][min(quest_stage,5)]

func _enter_village():
 if not door_open: _say(_t("Pehle darwaza kholo.","Open the door first."),1.5); return
 mode="village"; village_player=Vector2(180,158)

func _return_cafe(): mode="cafe"; player=Vector2(154,146)

func _save():
 StarlightGameState.cafe_opened=cafe_opened; StarlightGameState.player_position=player
 StarlightGameState.story_flags["quest_stage"]=quest_stage; StarlightGameState.story_flags["language"]=language
 _say(_t("Game save ho gaya.","Game saved."),2) if StarlightSaveManager.save_game() else _say("Save failed.",2)

func _touch_move(v): touch_move=v; StarlightGameState.touch_move=v
func _touch_interact(): dialogue.advance() if dialogue.active else _interact()
func _dialogue_finished(): _quest()
func _say(s,t=2): msg=s; msg_time=t
func _t(hi,en): return hi if language=="HI" else en

func _draw():
 if mode=="title": _title()
 elif mode=="village": _village()
 else: _cafe()

func _title():
 draw_rect(Rect2(0,0,384,216),Color("#0e1426"))
 # Star field + moon glow.
 for i in range(28):
  var sx=8+(i*47)%368
  var sy=8+(i*29)%88
  draw_rect(Rect2(sx,sy,2,2),Color("#e8d8b4"))
 draw_circle(Vector2(300,48),27,Color(0.62,0.54,0.86,0.10))
 draw_circle(Vector2(300,48),18,Color("#efe5c0"))
 draw_circle(Vector2(307,42),18,Color("#0e1426"))
 # Tiny café silhouette.
 draw_colored_polygon(PackedVector2Array([Vector2(71,151),Vector2(313,151),Vector2(295,115),Vector2(91,115)]),Color("#463341"))
 draw_colored_polygon(PackedVector2Array([Vector2(61,115),Vector2(323,115),Vector2(192,83)]),Color("#6b3f3e"))
 draw_colored_polygon(PackedVector2Array([Vector2(84,151),Vector2(84,132),Vector2(121,132),Vector2(121,151)]),Color("#3c3440"))
 draw_colored_polygon(PackedVector2Array([Vector2(264,151),Vector2(264,132),Vector2(301,132),Vector2(301,151)]),Color("#3c3440"))
 draw_rect(Rect2(167,128,46,23),Color("#302934"))
 draw_rect(Rect2(174,134,12,10),Color("#efb95e")); draw_rect(Rect2(194,134,12,10),Color("#efb95e"))
 # Lanterns.
 for p in [Vector2(108,108),Vector2(275,108)]:
  draw_line(p+Vector2(0,-10),p,Color("#30272e"),1); draw_rect(Rect2(p.x-4,p.y,8,6),Color("#d49a55")); draw_rect(Rect2(p.x-2,p.y+1,4,4),Color("#ffe08b"))
 # Logo + menu card.
 draw_string(font,Vector2(62,42),"STARLIGHT CAFÉ",HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("#ffe5ad"))
 draw_string(font,Vector2(132,57),"RAAT KA MENU",HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("#d2bfdb"))
 draw_rect(Rect2(118,156,148,43),Color(0.05,0.04,0.09,0.92))
 draw_rect(Rect2(120,158,144,39),Color("#6d4d68"),false,2)
 draw_string(font,Vector2(130,171),_t("TAP / E  START GAME","TAP / E  START GAME"),HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("#fff1c7"))
 draw_string(font,Vector2(134,184),"CONTINUE     SETTINGS",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#d9c9df"))
 draw_string(font,Vector2(154,194),"EN / HI: "+language,HORIZONTAL_ALIGNMENT_LEFT,-1,6,Color("#e9bf7d"))



func _cafe():
 var night=StarlightGameState.phase=="night"
 draw_rect(Rect2(0,0,384,216),Color("#101522") if night else Color("#2c3140"))
 _draw_room_shell(night)
 _draw_floor_tiles(night)
 _draw_rugs(night)
 _draw_back_wall_details(night)
 _draw_kitchen_cluster(night)
 _draw_lounge_cluster(night)
 _draw_dining_cluster(night)
 _draw_plants_and_props(night)
 _draw_cafe_characters(night)
 _draw_pet(night)

 _draw_pixel_finish(night)
 if night: _draw_night_motes()
 _draw_interaction_hint(night)
 var points={"moon_mushroom":Vector2(135,176),"village_herb":Vector2(333,153),"milk":Vector2(214,49),"salt":Vector2(176,47),"honey":Vector2(258,48),"grain":Vector2(198,48)}
 for id in points:
  if not gathered.has(str(StarlightGameState.day)+"_"+id):
   var pp:Vector2=points[id]
   draw_rect(Rect2(pp.x-2,pp.y-4,5,5),Color("#e8d99a") if not night else Color("#c9b9ff"))
 if door_open:
  draw_rect(Rect2(334,157,20,22),Color("#111522"))
  draw_line(Vector2(334,157),Vector2(334,179),Color("#b16d4c"),3)
  draw_string(font,Vector2(346,170),"→",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("#f3c878"))
 draw_rect(Rect2(7,7,370,28),Color(0.04,0.035,0.07,0.91))
 draw_string(font,Vector2(14,25),"Day "+str(StarlightGameState.day)+" • "+("NIGHT" if night else "DAY"),HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#f6dfad"))
 draw_string(font,Vector2(142,25),"E Use  I Bag  R Recipes  Q Quest  V Village",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#d8cfe4"))
 draw_string(font,Vector2(14,210),"P Save • F Settings • L Language",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#d8cfe4"))
 if panel=="inventory": _panel("INVENTORY",_inventory())
 if panel=="recipes": _panel("RECIPES",_recipes())
 if panel=="quest": _panel("QUEST",[_quest_text(),"","Q / CLOSE"])
 if panel=="settings": _panel("SETTINGS",["L Language: "+language,"N Night • D Day","V Village • P Save","F Close"])
 if cooking!="":
  draw_rect(Rect2(110,108,164,12),Color("#211a29"))
  draw_rect(Rect2(112,110,160*clampf(cook_time/cook_len,0,1),4),Color("#e0a45e"))
  draw_string(font,Vector2(116,119),"COOKING "+str(int(clampf(cook_time/cook_len,0,1)*100.0))+"%",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#ffe2aa"))
 if msg_time>0:
  draw_rect(Rect2(45,142,294,19),Color(0.06,0.04,0.1,0.92)); draw_string(font,Vector2(55,155),msg,HORIZONTAL_ALIGNMENT_LEFT,274,8,Color("#f2e6d0"))

func _draw_room_shell(night:bool)->void:
 var wall_base=Color("#482d35") if night else Color("#934f4b")
 var wall_shadow=Color("#3b2933") if night else Color("#724047")
 var brick_light=Color("#a45b4e") if not night else Color("#6b4654")
 var wood=Color("#593a36") if not night else Color("#3a2c38")
 draw_colored_polygon(PackedVector2Array([Vector2(12,78),Vector2(190,18),Vector2(372,78),Vector2(190,132)]),wall_base)
 draw_colored_polygon(PackedVector2Array([Vector2(12,78),Vector2(190,132),Vector2(190,207),Vector2(12,119)]),wall_shadow)
 draw_colored_polygon(PackedVector2Array([Vector2(190,132),Vector2(372,78),Vector2(372,119),Vector2(190,207)]),Color("#432d37") if night else Color("#6b3d3e"))
 for row in range(4):
  var yy=39+row*11
  var inset=float(row%2)*9.0
  draw_line(Vector2(49+inset,yy),Vector2(190,yy+47),brick_light,1)
  draw_line(Vector2(190,yy+47),Vector2(331-inset,yy),brick_light,1)
  for k in range(7):
   var lx=57+k*19+inset
   draw_rect(Rect2(lx,yy-2,9,2),Color("#6d3f3f") if not night else Color("#4e3544"))
 for p in [Vector2(57,63),Vector2(190,19),Vector2(323,63)]:
  draw_rect(Rect2(p.x-3,p.y,6,65),wood)
  draw_rect(Rect2(p.x-6,p.y+5,12,4),Color("#9b6245") if not night else Color("#5a3c45"))
 draw_line(Vector2(13,78),Vector2(190,132),Color("#c16f4e") if not night else Color("#745166"),3)
 draw_line(Vector2(190,132),Vector2(371,78),Color("#b8624a") if not night else Color("#6a4a60"),3)
 for p in [Vector2(18,154),Vector2(34,168),Vector2(354,153),Vector2(339,177)]:
  draw_circle(p,15,Color("#173729") if night else Color("#244b36"))
  draw_circle(p+Vector2(-5,-5),9,Color("#2b6240") if night else Color("#3f7a4b"))
 _draw_iso_window(Vector2(86,60),night)
 _draw_iso_window(Vector2(291,60),night)
 draw_colored_polygon(PackedVector2Array([Vector2(329,103),Vector2(352,96),Vector2(352,153),Vector2(329,161)]),Color("#3f2b34") if night else Color("#694038"))
 draw_rect(Rect2(329,103,3,57),Color("#c07955") if not night else Color("#755167"))
 draw_colored_polygon(PackedVector2Array([Vector2(10,160),Vector2(190,213),Vector2(373,160),Vector2(373,174),Vector2(190,216),Vector2(10,174)]),Color("#493335") if night else Color("#70443d"))
 for x in range(25,360,24): draw_rect(Rect2(x,164,3,9),Color("#8b5944") if not night else Color("#55404a"))


func _draw_floor_tiles(night:bool)->void:
 var top=Color("#51455a") if night else Color("#a86d4d")
 var alt=Color("#493e50") if night else Color("#996247")
 for y in range(0,5):
  for x in range(0,7):
   var p=Vector2(190,126)+Vector2((x-y)*32,(x+y)*16)
   var c=top if (x+y)%2==0 else alt
   draw_colored_polygon(PackedVector2Array([p+Vector2(0,-16),p+Vector2(32,0),p+Vector2(0,16),p+Vector2(-32,0)]),c)
   draw_line(p+Vector2(-28,0),p,Color(0.12,0.08,0.11,0.38),1); draw_line(p,p+Vector2(28,0),Color(0.12,0.08,0.11,0.24),1)

func _draw_rugs(night:bool)->void:
 _draw_iso_rug(Vector2(103,146),Vector2(64,30),Color("#5f3344") if night else Color("#a34445"))
 _draw_iso_rug(Vector2(279,157),Vector2(52,25),Color("#34496b") if night else Color("#3e6173"))

func _draw_iso_rug(c:Vector2,size:Vector2,col:Color)->void:
 var hw=size.x*0.5; var hh=size.y*0.5
 draw_colored_polygon(PackedVector2Array([c+Vector2(0,-hh),c+Vector2(hw,0),c+Vector2(0,hh),c-Vector2(hw,0)]),col)
 draw_polyline(PackedVector2Array([c+Vector2(0,-hh+2),c+Vector2(hw-3,0),c+Vector2(0,hh-2),c-Vector2(hw-3,0),c+Vector2(0,-hh+2)]),Color("#e0b06a"),1)

func _draw_back_wall_details(night:bool)->void:
 draw_rect(Rect2(40,58,34,24),Color("#30252d") if night else Color("#5d3b37"))
 draw_rect(Rect2(44,61,26,18),Color("#4d7891") if not night else Color("#4f4b76"))
 draw_colored_polygon(PackedVector2Array([Vector2(46,76),Vector2(56,67),Vector2(60,73),Vector2(66,66),Vector2(69,77)]),Color("#4d774f"))
 draw_line(Vector2(45,62),Vector2(69,62),Color("#d5a55f") if not night else Color("#846c80"),1)
 draw_rect(Rect2(108,47,68,5),Color("#70463b") if not night else Color("#49333c"))
 draw_rect(Rect2(112,53,60,3),Color("#4a3137") if not night else Color("#30272f"))
 for i in range(6):
  var xx=114+i*9
  draw_rect(Rect2(xx,57,7,13),Color("#9b6246") if i%2==0 else Color("#5e7c61"))
  draw_rect(Rect2(xx+1,56,5,2),Color("#e1b56b") if i%2==0 else Color("#7e9b72"))
 for p in [Vector2(119,45),Vector2(157,44)]:
  draw_rect(Rect2(p.x-4,p.y+4,8,5),Color("#81513f"))
  draw_rect(Rect2(p.x-8,p.y,5,5),Color("#4e8252"))
  draw_rect(Rect2(p.x+2,p.y-1,5,6),Color("#5d9360"))
 for i in range(6):
  var x=207+i*14
  draw_line(Vector2(x,45),Vector2(x+7,53),Color("#5a3543") if night else Color("#70413d"),1)
  draw_colored_polygon(PackedVector2Array([Vector2(x+3,50),Vector2(x+8,50),Vector2(x+6,58)]), [Color("#b75b59"),Color("#e7ae5b"),Color("#5b8291"),Color("#7e5d86")][i%4])
 draw_rect(Rect2(309,61,21,21),Color("#4b3438") if not night else Color("#2e2932"))
 draw_circle(Vector2(319,71),7,Color("#efe2b7"))
 draw_line(Vector2(319,71),Vector2(319,66),Color("#624853"),1)
 draw_line(Vector2(319,71),Vector2(324,74),Color("#624853"),1)
 draw_rect(Rect2(309,85,22,17),Color("#563c3f") if not night else Color("#3a2f38"))
 draw_rect(Rect2(312,88,5,6),Color("#e1b16c")); draw_rect(Rect2(320,88,7,7),Color("#8ea06f"))
 _draw_lamp(Vector2(149,52),night); _draw_lamp(Vector2(239,52),night)


func _draw_kitchen_cluster(night:bool)->void:
 var counter_top=Color("#a56443") if not night else Color("#654348")
 var counter_front=Color("#653e39") if not night else Color("#3b2d38")
 draw_colored_polygon(PackedVector2Array([Vector2(145,82),Vector2(264,46),Vector2(307,58),Vector2(184,101)]),counter_top)
 draw_colored_polygon(PackedVector2Array([Vector2(145,82),Vector2(184,101),Vector2(184,115),Vector2(145,96)]),Color("#4a3035") if not night else Color("#322a34"))
 draw_colored_polygon(PackedVector2Array([Vector2(184,101),Vector2(307,58),Vector2(307,73),Vector2(184,115)]),counter_front)
 for i in range(6):
  var x=192+i*17
  draw_rect(Rect2(x,83-i*2,11,13),Color("#5a3839") if not night else Color("#342a33"))
  draw_rect(Rect2(x+2,85-i*2,7,8),Color("#74473c") if not night else Color("#4b3440"))
  draw_rect(Rect2(x+4,86-i*2,3,2),Color("#d49a58") if not night else Color("#7f6172"))
 for i in range(6):
  var x=191+i*16
  draw_rect(Rect2(x,73-i*2,9,10),Color("#734a3e") if not night else Color("#49343d"))
  draw_rect(Rect2(x+2,76-i*2,5,5), [Color("#e4b25f"),Color("#86a86f"),Color("#ba6f58"),Color("#d3c075"),Color("#7893ad"),Color("#d78b4e")][i])
 for i in range(5):
  var xx=207+i*13
  draw_line(Vector2(xx,63),Vector2(xx,71),Color("#2f2930"),1)
  draw_circle(Vector2(xx,75),4,Color("#69636a") if not night else Color("#4c4950"))
  draw_rect(Rect2(xx-1,74,2,3),Color("#b78d69"))
 draw_rect(Rect2(171,72,22,13),Color("#8d7c78"))
 draw_rect(Rect2(175,75,14,7),Color("#455963"))
 draw_line(Vector2(186,73),Vector2(186,67),Color("#96999a"),2)
 draw_line(Vector2(186,67),Vector2(191,67),Color("#96999a"),2)
 draw_rect(Rect2(253,70,38,47),Color("#29252c"))
 draw_rect(Rect2(258,77,28,20),Color("#473035"))
 draw_rect(Rect2(263,80,18,14),Color("#e07b39") if not night else Color("#a84f42"))
 draw_rect(Rect2(267,82,10,9),Color("#ffd06a"))
 draw_rect(Rect2(267,44,10,28),Color("#333039"))
 draw_rect(Rect2(264,43,16,4),Color("#52464e"))
 draw_rect(Rect2(266,70,12,6),Color("#9d7f63")); draw_circle(Vector2(272,69),5,Color("#b49a72"))
 draw_line(Vector2(224,64),Vector2(224,72),Color("#2e2930"),1); draw_circle(Vector2(224,75),4,Color("#626067"))
 for p in [Vector2(292,106),Vector2(302,109),Vector2(295,114)]:
  draw_rect(Rect2(p.x-7,p.y-4,14,8),Color("#885a3c") if not night else Color("#59413b"))
  draw_line(p+Vector2(-5,-1),p+Vector2(5,-1),Color("#c07a45") if not night else Color("#745247"),1)


func _draw_lounge_cluster(night:bool)->void:
 draw_colored_polygon(PackedVector2Array([Vector2(44,126),Vector2(79,115),Vector2(119,128),Vector2(85,143)]),Color("#4f6f49") if not night else Color("#304a3e"))
 draw_colored_polygon(PackedVector2Array([Vector2(44,126),Vector2(85,143),Vector2(85,158),Vector2(44,140)]),Color("#39523f") if not night else Color("#263a36"))
 draw_colored_polygon(PackedVector2Array([Vector2(85,143),Vector2(119,128),Vector2(119,143),Vector2(85,158)]),Color("#3b5941") if not night else Color("#2b413b"))
 draw_rect(Rect2(60,119,17,8),Color("#638450") if not night else Color("#3f5a4a"))
 draw_rect(Rect2(81,126,15,7),Color("#748c56") if not night else Color("#465f4d"))
 draw_rect(Rect2(88,129,16,8),Color("#9c4c4f") if not night else Color("#673447"))
 for x in [91,96,101]: draw_rect(Rect2(x,131,2,4),Color("#e3b05e"))
 draw_colored_polygon(PackedVector2Array([Vector2(62,149),Vector2(77,144),Vector2(95,150),Vector2(79,156)]),Color("#8a573e"))
 draw_rect(Rect2(70,148,17,7),Color("#5c3b39"))
 draw_rect(Rect2(76,145,4,3),Color("#d6bea0")); draw_circle(Vector2(78,144),3,Color("#e0b56c"))
 draw_line(Vector2(53,125),Vector2(53,143),Color("#49332f"),2)
 draw_colored_polygon(PackedVector2Array([Vector2(48,126),Vector2(58,126),Vector2(60,136),Vector2(46,136)]),Color("#e0ad66"))
 draw_rect(Rect2(51,137,4,3),Color("#4d3432"))


func _draw_dining_cluster(night:bool)->void:
 _draw_iso_table(Vector2(184,135),Vector2(56,27),night); _draw_iso_table(Vector2(276,139),Vector2(44,22),night); _draw_iso_table(Vector2(216,169),Vector2(48,24),night)
 for p in [Vector2(156,142),Vector2(213,129),Vector2(258,151),Vector2(299,135),Vector2(224,181)]: _draw_iso_chair(p,night)

func _draw_iso_table(c:Vector2,size:Vector2,night:bool)->void:
 var hw=size.x*0.5; var hh=size.y*0.5
 var top=Color("#a86a43") if not night else Color("#754632")
 var side_l=Color("#7d4c3c") if not night else Color("#53363a")
 var side_r=Color("#704237") if not night else Color("#493139")
 draw_colored_polygon(PackedVector2Array([c+Vector2(0,-hh),c+Vector2(hw,0),c+Vector2(0,hh),c-Vector2(hw,0)]),top)
 draw_colored_polygon(PackedVector2Array([c+Vector2(-hw,0),c,c+Vector2(0,hh),c-Vector2(hw,0)]),side_l)
 draw_colored_polygon(PackedVector2Array([c,c+Vector2(hw,0),c+Vector2(0,hh),c-Vector2(hw,0)]),side_r)
 draw_line(c+Vector2(-hw+4,0),c+Vector2(hw-4,0),Color("#d08b52"),1)
 # Table runner + place setting.
 draw_line(c+Vector2(-8,-2),c+Vector2(9,3),Color("#a74449") if not night else Color("#7e4c62"),3)
 draw_circle(c+Vector2(4,-2),3,Color("#d6c3a0"))
 draw_rect(Rect2(c+Vector2(2,-5),Vector2(4,2)),Color("#7c5b4e"))
 draw_rect(Rect2(c+Vector2(-11,1),Vector2(5,2)),Color("#d5b46f"))


func _draw_iso_chair(p:Vector2,night:bool)->void:
 var wood=Color("#654039") if not night else Color("#3c2a31")
 var hi=Color("#a96b45") if not night else Color("#8b5a43")
 draw_rect(Rect2(p.x-6,p.y-13,12,6),wood)
 draw_rect(Rect2(p.x-5,p.y-12,10,2),hi)
 draw_colored_polygon(PackedVector2Array([p+Vector2(-8,-6),p+Vector2(8,-6),p+Vector2(7,4),p+Vector2(-7,4)]),hi)
 draw_rect(Rect2(p.x-5,p.y+1,10,3),wood)
 draw_line(p+Vector2(-5,4),p+Vector2(-7,15),wood,2)
 draw_line(p+Vector2(5,4),p+Vector2(7,15),wood,2)



func _draw_plants_and_props(night:bool)->void:
 var plant_points=[Vector2(35,111),Vector2(335,105),Vector2(300,94),Vector2(128,88),Vector2(312,153),Vector2(96,175)]
 for p in plant_points:
  draw_rect(Rect2(p.x-6,p.y+5,12,9),Color("#7b503e") if not night else Color("#4f3940"))
  draw_rect(Rect2(p.x-5,p.y+3,10,3),Color("#aa6a46"))
  for off in [Vector2(-6,1),Vector2(0,-5),Vector2(6,1),Vector2(2,5)]:
   draw_rect(Rect2(p+off,Vector2(5,5)),Color("#3d7148") if not night else Color("#2d523f"))
  draw_rect(Rect2(p.x-2,p.y-7,3,3),Color("#df8a87") if not night else Color("#8d6179"))
 for p in [Vector2(325,173),Vector2(314,179),Vector2(337,180),Vector2(106,178)]:
  draw_rect(Rect2(p.x-7,p.y-5,14,8),Color("#76503c") if not night else Color("#503a3a"))
  draw_line(p+Vector2(-5,-2),p+Vector2(5,-2),Color("#b47a49") if not night else Color("#79534b"),1)
  draw_line(p+Vector2(0,-5),p+Vector2(0,2),Color("#b47a49") if not night else Color("#79534b"),1)
 for p in [Vector2(145,188),Vector2(160,191),Vector2(290,186),Vector2(305,182)]:
  draw_rect(Rect2(p.x-4,p.y+2,8,5),Color("#76503f"))
  draw_rect(Rect2(p.x-5,p.y-2,4,4),Color("#e2a06c"))
  draw_rect(Rect2(p.x+1,p.y-3,4,4),Color("#f0c076"))


func _draw_iso_window(p:Vector2,night:bool)->void:
 var frame=Color("#5b3b37") if not night else Color("#342b38")
 var glass=Color("#6e94a1") if not night else Color("#4c4671")
 draw_rect(Rect2(p.x-24,p.y-13,48,33),Color("#2b2028"))
 draw_rect(Rect2(p.x-20,p.y-9,40,25),frame)
 draw_rect(Rect2(p.x-17,p.y-6,34,19),glass)
 draw_line(Vector2(p.x,p.y-6),Vector2(p.x,p.y+13),Color("#4a3337"),2)
 draw_line(Vector2(p.x-17,p.y+4),Vector2(p.x+17,p.y+4),Color("#4a3337"),2)
 # Curtains and sill.
 draw_colored_polygon(PackedVector2Array([Vector2(p.x-22,p.y-11),Vector2(p.x-17,p.y-9),Vector2(p.x-18,p.y+14),Vector2(p.x-24,p.y+10)]),Color("#f0d7b0") if not night else Color("#806a86"))
 draw_colored_polygon(PackedVector2Array([Vector2(p.x+22,p.y-11),Vector2(p.x+17,p.y-9),Vector2(p.x+18,p.y+14),Vector2(p.x+24,p.y+10)]),Color("#ecd3ad") if not night else Color("#78637f"))
 draw_rect(Rect2(p.x-21,p.y+14,42,3),Color("#7c5947") if not night else Color("#493945"))
 # Outside greenery / moon.
 if not night:
  draw_colored_polygon(PackedVector2Array([p+Vector2(-15,13),p+Vector2(-6,5),p+Vector2(0,13)]),Color("#51745a"))
  draw_colored_polygon(PackedVector2Array([p+Vector2(2,13),p+Vector2(11,4),p+Vector2(16,13)]),Color("#3f624f"))
  draw_rect(Rect2(p.x-4,p.y+8,8,3),Color("#f2d17c"))
 else:
  draw_circle(p+Vector2(7,-1),5,Color("#e5d2a2"))



func _draw_cafe_characters(night:bool)->void:
 # Two tiny daytime customers keep the room visually alive; spirits replace them at night.
 if not night:
  _draw_guest(Vector2(260,145),Color("#cf8b72"),Color("#5b728c"),false)
  _draw_guest(Vector2(315,150),Color("#b87963"),Color("#7a5c46"),true)
  var bubble=Color("#2e2635")
  draw_rect(Rect2(244,124,40,10),bubble)
  draw_rect(Rect2(246,126,36,6),Color("#8b6a7e"))
  var order_text="READY" if StarlightGameState.current_recipe!="" else "ORDER"
  draw_string(font,Vector2(249,132),order_text,HORIZONTAL_ALIGNMENT_LEFT,-1,6,Color("#ffe7b0"))
 else:
  # Aoi / Ren spirit glow at the story table.
  var glow=Color(0.60,0.42,0.95,0.10)
  draw_circle(Vector2(235,116),15,glow)
  draw_circle(Vector2(235,116),9,Color(0.47,0.35,0.75,0.65))
  draw_circle(Vector2(231,114),2,Color("#e8dcff"))
  draw_circle(Vector2(239,114),2,Color("#e8dcff"))
  draw_rect(Rect2(230,118,10,5),Color("#73579a"))
  # Small spirit particles.
  for p in [Vector2(223,106),Vector2(246,109),Vector2(242,126)]:
   draw_rect(Rect2(p.x,p.y,2,2),Color("#d7c6ff"))
 
func _draw_guest(p:Vector2,skin:Color,cloth:Color,hat:bool)->void:
 draw_circle(p+Vector2(0,-6),5,skin)
 if hat: draw_rect(Rect2(p.x-6,p.y-12,12,4),Color("#4c4d63")); draw_rect(Rect2(p.x-4,p.y-15,8,3),Color("#5d6579"))
 draw_colored_polygon(PackedVector2Array([p+Vector2(-5,-1),p+Vector2(5,-1),p+Vector2(7,9),p+Vector2(-7,9)]),cloth)
 draw_rect(Rect2(p.x-5,p.y+9,4,5),Color("#2f2931"))
 draw_rect(Rect2(p.x+1,p.y+9,4,5),Color("#2f2931"))

func _draw_pet(night:bool)->void:
 var p=Vector2(player.x+18,player.y+10) if mode=="cafe" else Vector2(0,0)
 if mode!="cafe": return
 # Tiny fluffy white companion, kept separate from Yui's sprite.
 draw_circle(p+Vector2(0,2),7,Color("#2e2732"))
 draw_circle(p+Vector2(-4,-2),5,Color("#f4efe7"))
 draw_circle(p+Vector2(4,-3),5,Color("#efe8de"))
 draw_circle(p+Vector2(0,-6),5,Color("#fff8ef"))
 draw_rect(Rect2(p.x-2,p.y+5,4,3),Color("#b5a39a"))
 draw_rect(Rect2(p.x-5,p.y+1,2,2),Color("#2b2430"))
 draw_rect(Rect2(p.x+3,p.y+1,2,2),Color("#2b2430"))
 if night:
  draw_rect(Rect2(p.x-1,p.y-9,2,2),Color("#d9c7ff"))

func _draw_pixel_finish(night:bool)->void:
 # Hand-authored pixel clusters: hard edges, limited palette, consistent upper-left light.
 var outline=Color("#241c28") if not night else Color("#171522")
 var wood=Color("#8f573c") if not night else Color("#573b3d")
 var wood_hi=Color("#d08a50") if not night else Color("#8e5b4c")
 var wood_sh=Color("#57333a") if not night else Color("#342839")
 # Structural dark seams and chunky timber joints.
 for p in [Vector2(64,60),Vector2(190,25),Vector2(316,60)]:
  draw_rect(Rect2(p.x-2,p.y,4,8),outline)
  draw_rect(Rect2(p.x-4,p.y+7,8,3),wood_sh)
 # Floor plank grain: sparse 1px clusters, never noisy.
 for p in [Vector2(132,132),Vector2(164,148),Vector2(202,139),Vector2(242,153),Vector2(286,128),Vector2(116,166),Vector2(252,178)]:
  draw_line(p,p+Vector2(9,3),wood_hi if not night else Color("#76505a"),1)
  draw_line(p+Vector2(12,4),p+Vector2(16,5),outline,1)
 # Table construction details and readable silhouettes.
 for p in [Vector2(184,135),Vector2(276,139),Vector2(216,169)]:
  draw_line(p+Vector2(-17,-4),p+Vector2(17,4),outline,1)
  draw_line(p+Vector2(-7,6),p+Vector2(-10,16),wood_sh,2)
  draw_line(p+Vector2(7,6),p+Vector2(10,16),wood_sh,2)
  draw_rect(Rect2(p+Vector2(-5,-2),Vector2(3,2)),wood_hi)
 # Chair backs, seats and tiny joinery pixels.
 for p in [Vector2(156,142),Vector2(213,129),Vector2(258,151),Vector2(299,135),Vector2(224,181)]:
  draw_rect(Rect2(p.x-7,p.y-13,14,3),outline)
  draw_rect(Rect2(p.x-5,p.y-12,10,2),wood_hi)
  draw_rect(Rect2(p.x-5,p.y+3,10,2),wood_sh)
 # Kitchen jars get individual labels/highlights; stove gets four readable burners.
 for i in range(4):
  var bx=193+i*16
  draw_rect(Rect2(bx+1,77-i*2,7,1),outline)
  draw_rect(Rect2(bx+2,79-i*2,2,4),wood_hi)
 for i in range(4):
  var bx=261+i*6
  draw_rect(Rect2(bx,73,4,2),outline)
  draw_rect(Rect2(bx+1,74,2,1),Color("#e9b86a") if not night else Color("#9b6171"))
 # Café sign plaque and star motif.
 draw_rect(Rect2(154,31,72,12),outline)
 draw_rect(Rect2(157,33,66,8),wood_sh)
 draw_string(font,Vector2(169,40),"STARLIGHT",HORIZONTAL_ALIGNMENT_LEFT,-1,6,Color("#f0c66f") if not night else Color("#d2b8f0"))
 draw_rect(Rect2(187,34,3,3),Color("#ffe5a1") if not night else Color("#e5d5ff"))
 # Door hardware.
 if door_open:
  draw_rect(Rect2(338,165,3,3),Color("#e2b76a"))
 else:
  draw_rect(Rect2(340,168,3,3),Color("#d99a52"))
 # Pixel-level night atmosphere around light sources.
 if night:
  for p in [Vector2(148,55),Vector2(235,55),Vector2(267,86)]:
   draw_rect(Rect2(p-Vector2(2,2),Vector2(4,4)),Color("#f5c86b"))
   draw_rect(Rect2(p-Vector2(5,5),Vector2(10,1)),Color(0.95,0.62,0.25,0.08))

func _draw_night_motes()->void:
 for i in range(18):
  var x=25+(i*47)%335; var y=43+(i*31)%130; draw_rect(Rect2(x,y,2,2),Color(0.75,0.67,1.0,0.42))

func _village()->void:
 draw_rect(Rect2(0,0,384,216),Color("#182536"))
 # Main village ground: broad isometric street with warm earth border.
 draw_colored_polygon(PackedVector2Array([
  Vector2(28,70),Vector2(190,26),Vector2(356,70),Vector2(356,171),Vector2(190,205),Vector2(28,171)
 ]),Color("#334b4a"))
 draw_colored_polygon(PackedVector2Array([
  Vector2(45,83),Vector2(190,44),Vector2(340,83),Vector2(340,157),Vector2(190,190),Vector2(45,157)
 ]),Color("#5a5b48"))
 # 2:1 cobble/earth path.
 for y in range(0,8):
  for x in range(0,7):
   var p=Vector2(190,118)+Vector2((x-y)*28,(x+y)*14)
   var cc=Color("#75624c") if (x+y)%2==0 else Color("#685745")
   draw_colored_polygon(PackedVector2Array([p+Vector2(0,-7),p+Vector2(14,0),p+Vector2(0,7),p+Vector2(-14,0)]),cc)
   draw_rect(Rect2(p.x-2,p.y-1,4,2),Color("#8a7257"))
 # Greenhollow title plaque.
 draw_rect(Rect2(52,48,124,17),Color("#272332"))
 draw_rect(Rect2(55,50,118,12),Color("#67464b"))
 draw_string(font,Vector2(64,59),"GREENHOLLOW",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("#ffe1a4"))
 # Inn.
 draw_colored_polygon(PackedVector2Array([Vector2(126,60),Vector2(194,60),Vector2(194,101),Vector2(126,101)]),Color("#755147"))
 draw_colored_polygon(PackedVector2Array([Vector2(120,60),Vector2(200,60),Vector2(160,41)]),Color("#4c3b4b"))
 draw_rect(Rect2(151,74,18,27),Color("#3a3035"))
 draw_rect(Rect2(134,69,10,10),Color("#8aa1a2")); draw_rect(Rect2(176,69,10,10),Color("#8aa1a2"))
 draw_string(font,Vector2(144,57),"INN",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#ffd88d"))
 # Bazaar.
 draw_colored_polygon(PackedVector2Array([Vector2(72,79),Vector2(122,79),Vector2(122,106),Vector2(72,106)]),Color("#71483f"))
 draw_colored_polygon(PackedVector2Array([Vector2(67,79),Vector2(127,79),Vector2(97,64)]),Color("#584049"))
 draw_rect(Rect2(82,88,12,11),Color("#9b6745")); draw_rect(Rect2(99,88,12,11),Color("#6d8b63"))
 draw_string(font,Vector2(76,75),"BAZAAR",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#f5cb88"))
 # Shrine.
 draw_rect(Rect2(200,108,46,30),Color("#81614e"))
 draw_colored_polygon(PackedVector2Array([Vector2(194,108),Vector2(252,108),Vector2(223,89)]),Color("#55445a"))
 draw_rect(Rect2(218,116,10,22),Color("#49373e"))
 draw_string(font,Vector2(205,147),"SHRINE",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#f2c98b"))
 # Well.
 draw_colored_polygon(PackedVector2Array([Vector2(269,118),Vector2(283,111),Vector2(298,118),Vector2(284,125)]),Color("#8a8272"))
 draw_rect(Rect2(274,118,20,15),Color("#655d57"))
 draw_colored_polygon(PackedVector2Array([Vector2(272,118),Vector2(284,109),Vector2(298,118),Vector2(284,126)]),Color("#4b4b56"))
 draw_circle(Vector2(284,118),7,Color("#273744"))
 # Trees.
 for p in [Vector2(58,114),Vector2(326,103),Vector2(74,146),Vector2(307,145)]:
  draw_rect(Rect2(p.x-4,p.y+8,8,10),Color("#75533e"))
  draw_circle(p+Vector2(-5,0),9,Color("#315b46")); draw_circle(p+Vector2(4,-2),10,Color("#3d704e")); draw_circle(p+Vector2(0,-8),9,Color("#4a7c55"))
  draw_rect(Rect2(p.x-2,p.y-11,4,4),Color("#84a05d"))
 # Fences and crops.
 for x in range(116,151,9):
  draw_rect(Rect2(x,120,4,18),Color("#684633"))
  draw_rect(Rect2(x-2,124,9,3),Color("#8c6040"))
 for p in [Vector2(127,115),Vector2(139,110),Vector2(151,116),Vector2(135,126)]:
  draw_rect(Rect2(p.x-3,p.y,6,5),Color("#5e934f")); draw_rect(Rect2(p.x-1,p.y-2,3,2),Color("#85b25e"))
 # Street lamps.
 for p in [Vector2(106,108),Vector2(315,118)]:
  draw_line(p+Vector2(0,-13),p+Vector2(0,4),Color("#2d2730"),2)
  draw_rect(Rect2(p.x-4,p.y-14,8,7),Color("#8e5d42"))
  draw_rect(Rect2(p.x-2,p.y-13,4,5),Color("#efbd62"))
 # NPCs with readable silhouettes.
 draw_circle(Vector2(108,92),7,Color("#d89b78")); draw_rect(Rect2(103,99,10,12),Color("#6b7894")); draw_rect(Rect2(101,106,14,4),Color("#4a5567"))
 draw_circle(Vector2(244,86),7,Color("#c78b70")); draw_rect(Rect2(239,93,10,12),Color("#8b6a48")); draw_rect(Rect2(237,104,14,4),Color("#5c473e"))
 # Yui anchor shadow + sprite drawn by StarlightYui node.
 draw_rect(Rect2(village_player.x-8,village_player.y+22,16,4),Color(0.06,0.04,0.07,0.32))
 draw_string(font,Vector2(58,176),"JOYSTICK / WASD  •  E INTERACT  •  V RETURN",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#ddd1e3"))

func _draw_counter() -> void:
 draw_rect(Rect2(178,44,86,78),Color("#2a202f"))
 draw_rect(Rect2(174,42,94,10),Color("#7a513f"))
 draw_rect(Rect2(178,52,86,7),Color("#b8794d"))
 draw_rect(Rect2(182,59,78,58),Color("#513747"))
 draw_rect(Rect2(182,59,78,4),Color("#d08b52"))
 for x in [190,210,230,250]:
  draw_rect(Rect2(x,78,12,30),Color("#6d4a45"))
  draw_rect(Rect2(x+2,80,8,26),Color("#392c3a"))

func _draw_table(center: Vector2) -> void:
 var p=center
 draw_colored_polygon(PackedVector2Array([p+Vector2(0,-18),p+Vector2(30,-7),p+Vector2(0,5),p+Vector2(-30,-7)]),Color("#9a6547"))
 draw_colored_polygon(PackedVector2Array([p+Vector2(0,-13),p+Vector2(23,-5),p+Vector2(0,2),p+Vector2(-23,-5)]),Color("#c58a54"))
 draw_colored_polygon(PackedVector2Array([p+Vector2(-18,-5),p+Vector2(-10,-1),p+Vector2(-10,19),p+Vector2(-16,22)]),Color("#563b37"))
 draw_colored_polygon(PackedVector2Array([p+Vector2(18,-5),p+Vector2(10,-1),p+Vector2(10,19),p+Vector2(16,22)]),Color("#432f32"))
 draw_line(p+Vector2(-14,-7),p+Vector2(14,-7),Color("#e1aa64"),2)

func _draw_chair(p: Vector2) -> void:
 draw_colored_polygon(PackedVector2Array([p+Vector2(-9,-10),p+Vector2(9,-10),p+Vector2(8,8),p+Vector2(-8,8)]),Color("#70483e"))
 draw_rect(Rect2(p+Vector2(-8,-8),Vector2(16,5)),Color("#b8784c"))
 draw_line(p+Vector2(-7,8),p+Vector2(-10,17),Color("#3b2b31"),3)
 draw_line(p+Vector2(7,8),p+Vector2(10,17),Color("#3b2b31"),3)

func _panel(title,lines):
 draw_rect(Rect2(48,45,288,118),Color(0.035,0.025,0.07,0.97)); draw_rect(Rect2(50,47,284,114),Color("#73516f"),false,2)
 draw_string(font,Vector2(66,67),title,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#ffe8ae"))
 var y=88
 for line in lines: draw_string(font,Vector2(66,y),str(line),HORIZONTAL_ALIGNMENT_LEFT,246,8,Color("#e8dce8")); y+=14

func _inventory():
 var a=[]; for k in StarlightGameState.inventory: a.append(k.replace("_"," ").capitalize()+": "+str(StarlightGameState.inventory[k]))
 a.append("Current dish: "+(StarlightGameState.current_recipe if StarlightGameState.current_recipe!="" else "none")); a.append("I / CLOSE"); return a

func _recipes():
 var a=[]
 for id in recipes:
  if id in StarlightGameState.unlocked_recipes: a.append(recipes[id].name+" • "+_ing(recipes[id].ingredients))
  else: a.append("LOCKED • "+recipes[id].name)
 a.append("R / CLOSE"); return a

func _ing(d):
 var s=""; for k in d: s+=k+" "+str(d[k])+" "
 return s

func _floor(night):
 var base=Color("#43394f") if night else Color("#4e3b38")
 for y in range(-3,8):
  for x in range(-3,10):
   var p=Vector2(190,110)+Vector2((x-y)*32,(x+y)*16)
   var tile=Color("#4a3e51") if night else Color("#684a3e")
   if (x+y)%2==0: tile=Color("#44394c") if night else Color("#5b4239")
   draw_colored_polygon(PackedVector2Array([p+Vector2(0,-16),p+Vector2(32,0),p+Vector2(0,16),p+Vector2(-32,0)]),tile)
   draw_line(p+Vector2(-18,0),p+Vector2(0,9),Color(0.12,0.09,0.13,0.35),1)
   draw_line(p+Vector2(0,9),p+Vector2(18,0),Color(0.12,0.09,0.13,0.25),1)

func _draw_cafe_backdrop(night: bool) -> void:
 var wall=Color("#30283b") if night else Color("#6e4b52")
 var trim=Color("#6f5879") if night else Color("#9a6653")
 draw_rect(Rect2(78,43,244,132),wall)
 draw_rect(Rect2(82,47,236,124),Color("#3b3044") if night else Color("#81555b"))
 # timber beams
 for x in [92,160,228,308]:
  draw_rect(Rect2(x,48,5,116),Color("#4b3541") if night else Color("#5b3d3d"))
 draw_rect(Rect2(84,68,232,6),trim)
 draw_rect(Rect2(84,158,232,7),Color("#392b38") if night else Color("#57383a"))
 # windows with four panes
 _draw_window(Vector2(108,56),night)
 _draw_window(Vector2(270,56),night)
 # hanging lamps
 _draw_lamp(Vector2(146,61),night)
 _draw_lamp(Vector2(238,61),night)
 # back shelf and jars
 draw_rect(Rect2(164,76,72,5),Color("#8d5b46"))
 draw_rect(Rect2(168,81,64,22),Color("#4b3540"))
 for i in range(6):
  var x=171+i*10
  draw_rect(Rect2(x,84,7,12),Color("#9b6a4d") if i%2==0 else Color("#6d7b65"))
  draw_circle(Vector2(x+3,84),3,Color("#d6aa62"))
 # plants
 _draw_plant(Vector2(95,105),night)
 _draw_plant(Vector2(306,103),night)

func _draw_window(p:Vector2,night:bool) -> void:
 draw_rect(Rect2(p.x-15,p.y-4,30,28),Color("#241d2b"))
 draw_rect(Rect2(p.x-11,p.y,22,20),Color("#6a5b8d") if night else Color("#e7b965"))
 draw_rect(Rect2(p.x-2,p.y,4,20),Color("#4c3947"))
 draw_rect(Rect2(p.x-11,p.y+8,22,4),Color("#4c3947"))
 if night:
  draw_circle(p+Vector2(4,6),8,Color(0.65,0.5,1.0,0.10))

func _draw_interaction_hint(night:bool)->void:
 if near_target=="" or panel!="" or dialogue.active: return
 var labels={"counter":"COOK","door":"DOOR","spirit":"SPIRIT","moon_mushroom":"MUSHROOM","village_herb":"HERB","milk":"MILK","salt":"SALT","honey":"HONEY","grain":"GRAIN"}
 var points={"moon_mushroom":Vector2(135,176),"village_herb":Vector2(333,153),"milk":Vector2(214,49),"salt":Vector2(176,47),"honey":Vector2(258,48),"grain":Vector2(198,48),"counter":Vector2(202,70),"door":Vector2(345,171),"spirit":Vector2(235,122)}
 var p:Vector2=points[near_target]
 var bob=sin(ui_pulse*4.0)*1.5
 draw_rect(Rect2(p.x-24,p.y-22+bob,48,11),Color(0.06,0.04,0.10,0.88))
 draw_string(font,Vector2(p.x-20,p.y-14+bob),str(labels.get(near_target,near_target)).to_upper(),HORIZONTAL_ALIGNMENT_LEFT,40,6,Color("#f4d99b") if not night else Color("#e8d9ff"))


func _draw_lamp(p:Vector2,night:bool) -> void:
 draw_line(p+Vector2(0,-12),p+Vector2(0,-2),Color("#352a35"),2)
 draw_rect(Rect2(p.x-5,p.y-1,10,7),Color("#a86e48"))
 draw_rect(Rect2(p.x-3,p.y,6,5),Color("#efbd62"))
 draw_circle(p+Vector2(0,3),10,Color(1.0,0.68,0.28,0.08) if night else Color(1.0,0.75,0.35,0.04))

func _draw_plant(p:Vector2,night:bool) -> void:
 draw_rect(Rect2(p.x-4,p.y+5,8,8),Color("#754b3d"))
 for off in [Vector2(-5,2),Vector2(0,-3),Vector2(5,2)]:
  draw_circle(p+off,5,Color("#456c4c") if night else Color("#5f8a50"))
