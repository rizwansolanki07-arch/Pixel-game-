extends Node2D

const CAFE := Rect2(76,48,250,128)
const SPEED := 95.0
const TABLE_TEX = preload("res://assets/starlight/props/cafe_table.png")
const CHAIR_TEX = preload("res://assets/starlight/props/cafe_chair.png")
const COUNTER_TEX = preload("res://assets/starlight/props/cafe_counter.png")

var player := Vector2(190,138)
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
 touch.move_changed.connect(_touch_move)
 touch.interact_pressed.connect(_touch_interact)
 dialogue.finished.connect(_dialogue_finished)
 if StarlightSaveManager.load_game():
  mode="cafe"; cafe_opened=StarlightGameState.cafe_opened; player=StarlightGameState.player_position
  quest_stage=int(StarlightGameState.story_flags.get("quest_stage",0))
  language=str(StarlightGameState.story_flags.get("language","EN"))
 queue_redraw()

func _process(delta):
 msg_time=maxf(0,msg_time-delta)
 if mode=="title": queue_redraw(); return
 if mode=="village": _move_village(delta)
 else:
  _move_cafe(delta)
  if cooking!="":
   cook_time+=delta
   if cook_time>=cook_len: _finish_cooking()
  yui.position=player
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
 if not CAFE.grow(-10).has_point(p): return false
 for b in [Rect2(176,43,88,47),Rect2(110,76,78,66),Rect2(266,93,78,66),Rect2(96,65,48,26)]:
  if b.grow(6).has_point(p): return false
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
 var t={"moon_mushroom":Vector2(118,155),"village_herb":Vector2(270,150),"milk":Vector2(286,92),"salt":Vector2(112,88),"honey":Vector2(300,115),"grain":Vector2(140,92),"counter":Vector2(222,78),"door":Vector2(213,70),"spirit":Vector2(235,116)}
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
 var key=str(StarlightGameState.day)+"_"+t
 if gathered.has(key): _say(_t("Aaj yahan se aur kuch nahi mila.","Nothing more here today."),1.5)
 else:
  var n=2 if t=="village_herb" or t=="grain" else 1
  StarlightGameState.add_item(t,n); gathered[key]=true; _say(t.replace("_"," ").capitalize()+" +"+str(n),2)
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

func _return_cafe(): mode="cafe"; player=Vector2(213,150)

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
 draw_rect(Rect2(0,0,384,216),Color("#17152a"))
 for i in range(22): draw_circle(Vector2(12+(i*53)%360,18+(i*29)%180),1.2,Color(0.9,0.78,0.58,0.45))
 draw_circle(Vector2(192,72),32,Color(0.55,0.4,0.85,0.18)); draw_circle(Vector2(192,72),22,Color("#e9c87a"))
 draw_string(font,Vector2(76,120),"STARLIGHT CAFÉ",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("#ffe5ad"))
 draw_string(font,Vector2(110,139),"RAAT KA MENU",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("#cbb9dd"))
 draw_string(font,Vector2(112,174),_t("E / TAP — Shuru karo","E / TAP — Start"),HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("#fff0c7"))

func _cafe():
 var night=StarlightGameState.phase=="night"
 draw_rect(Rect2(0,0,384,216),Color("#17152a") if night else Color("#c9a66b"))
 _floor(night)
 draw_rect(Rect2(88,48,216,22),Color("#3f3151") if night else Color("#8c5b62"))
 draw_rect(Rect2(108,51,28,18),Color("#30263b")); draw_rect(Rect2(111,54,22,12),Color("#554b87") if night else Color("#e6b85e"))
 draw_rect(Rect2(270,51,28,18),Color("#30263b")); draw_rect(Rect2(273,54,22,12),Color("#554b87") if night else Color("#e6b85e"))
 draw_rect(Rect2(196,49,34,23),Color("#302638")); draw_rect(Rect2(201,53,24,19),Color("#17142a") if door_open else Color("#9a604a"))
 draw_string(font,Vector2(154,46),"STARLIGHT",HORIZONTAL_ALIGNMENT_LEFT,-1,6,Color("#ffe3a5"))
 draw_texture_rect(COUNTER_TEX,Rect2(178,44,86,86),false)
 draw_texture_rect(TABLE_TEX,Rect2(112,77,72,72),false); draw_texture_rect(TABLE_TEX,Rect2(268,94,72,72),false)
 draw_texture_rect(CHAIR_TEX,Rect2(132,112,44,44),false); draw_texture_rect(CHAIR_TEX,Rect2(254,125,44,44),false); draw_texture_rect(CHAIR_TEX,Rect2(293,110,44,44),false)
 for id in ["moon_mushroom","village_herb","milk","salt","honey","grain"]:
  var p={"moon_mushroom":Vector2(118,155),"village_herb":Vector2(270,150),"milk":Vector2(286,92),"salt":Vector2(112,88),"honey":Vector2(300,115),"grain":Vector2(140,92)}[id]
  draw_circle(p,5,Color("#b8e37d") if not night else Color("#a18bd1"))
 if night:
  draw_circle(Vector2(235,116),13,Color(0.55,0.42,0.9,0.28)); draw_circle(Vector2(235,113),7,Color("#d8c9ff"))
 draw_rect(Rect2(7,7,370,28),Color(0.06,0.05,0.10,0.88))
 draw_string(font,Vector2(14,25),"Day "+str(StarlightGameState.day)+" • "+("NIGHT" if night else "DAY"),HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#f6dfad"))
 draw_string(font,Vector2(142,25),"E Use  I Bag  R Recipes  Q Quest  V Village",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#d8cfe4"))
 draw_string(font,Vector2(14,199),"P Save • F Settings • L Language",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#d8cfe4"))
 if panel=="inventory": _panel("INVENTORY",_inventory())
 if panel=="recipes": _panel("RECIPES",_recipes())
 if panel=="quest": _panel("QUEST",[_quest_text(),"","Q / CLOSE"])
 if panel=="settings": _panel("SETTINGS",["L Language: "+language,"N Night • D Day","V Village • P Save","F Close"])
 if cooking!="":
  draw_rect(Rect2(110,108,164,8),Color("#2e2536")); draw_rect(Rect2(112,110,160*clampf(cook_time/cook_len,0,1),4),Color("#e0a45e"))
 if msg_time>0: draw_rect(Rect2(45,142,294,19),Color(0.06,0.04,0.1,0.92)); draw_string(font,Vector2(55,155),msg,HORIZONTAL_ALIGNMENT_LEFT,274,8,Color("#f2e6d0"))

func _village():
 draw_rect(Rect2(0,0,384,216),Color("#182536")); draw_rect(Rect2(42,38,300,142),Color("#334b4a"))
 draw_colored_polygon(PackedVector2Array([Vector2(180,160),Vector2(204,160),Vector2(248,54),Vector2(224,54)]),Color("#b88a62"))
 for p in [Vector2(78,65),Vector2(302,65),Vector2(64,140),Vector2(318,140)]: draw_circle(p,15,Color("#284c42")); draw_circle(p+Vector2(-5,-4),8,Color("#3f6b50"))
 draw_rect(Rect2(132,58,58,40),Color("#745247")); draw_colored_polygon(PackedVector2Array([Vector2(126,60),Vector2(196,60),Vector2(161,42)]),Color("#4d4050")); draw_string(font,Vector2(143,55),"INN",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#f2c98b"))
 draw_rect(Rect2(94,76,32,22),Color("#704b3f")); draw_string(font,Vector2(92,63),"BAZAAR",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#f2c98b"))
 draw_rect(Rect2(220,62,48,34),Color("#76564c")); draw_colored_polygon(PackedVector2Array([Vector2(214,64),Vector2(274,64),Vector2(244,48)]),Color("#493d52"))
 draw_rect(Rect2(198,106,46,30),Color("#80634e")); draw_colored_polygon(PackedVector2Array([Vector2(192,108),Vector2(250,108),Vector2(221,90)]),Color("#5c4650")); draw_string(font,Vector2(204,145),"SHRINE",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#f2c98b"))
 draw_circle(Vector2(282,130),14,Color("#6e6262")); draw_circle(Vector2(282,130),9,Color("#293441"))
 for p in [Vector2(130,116),Vector2(142,112),Vector2(154,116),Vector2(136,126)]: draw_circle(p,4,Color("#8ab45f"))
 draw_circle(Vector2(108,92),7,Color("#d89b78")); draw_rect(Rect2(103,99,10,12),Color("#6b7894"))
 draw_circle(Vector2(244,86),7,Color("#c78b70")); draw_rect(Rect2(239,93,10,12),Color("#8b6a48"))
 draw_circle(village_player,7,Color("#e7b78f")); draw_rect(Rect2(village_player+Vector2(-5,4),Vector2(10,10)),Color("#c28b55"))
 draw_string(font,Vector2(58,57),"GREENHOLLOW VILLAGE",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("#ffe2a7"))
 draw_string(font,Vector2(58,172),"WASD / JOYSTICK • E INTERACT • V RETURN",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#ddd1e3"))

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
 var c=Color("#493e58") if night else Color("#355246")
 for y in range(-3,8):
  for x in range(-3,10):
   var p=Vector2(190,110)+Vector2((x-y)*32,(x+y)*16)
   draw_colored_polygon(PackedVector2Array([p+Vector2(0,-16),p+Vector2(32,0),p+Vector2(0,16),p+Vector2(-32,0)]),c)
